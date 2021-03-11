//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCache_uponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.requestedCommands, [])
    }

    func test_save_requestsCacheDeletion() {
        let feed = uniqueImagesFeed().models
        let (sut, store) = self.makeSUT()
        sut.save(feed) { _ in }
        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertion_onDeletionError() {
        let feed = uniqueImagesFeed().models
        let (sut, store) = self.makeSUT()
        let deletionError = anyNSError()

        sut.save(feed) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_requestsInsertionWithTimestamp_onSuccessfulDeletion() {
        let (feed, localFeed) = uniqueImagesFeed()
        let timestamp = Date()
        let (sut, store) = self.makeSUT(timestampProvider: { timestamp })

        sut.save(feed) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed, .insertCache(localFeed, timestamp)])
    }

    func test_save_fails_onDeletionError() {
        let (sut, store) = self.makeSUT()
        let deletionError = anyNSError()
        self.expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_fails_onInsertionError() {
        let (sut, store) = self.makeSUT()
        let insertionError = anyNSError()
        self.expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }

    func test_save_succeeds_onSuccessfulCacheInsertion() {
        let (sut, store) = self.makeSUT()
        self.expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    func test_save_doesNotDeliverDeletionError_afterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy.init()
        var sut: LocalFeedLoader? = LocalFeedLoader.init(store: store, timestampProvider: Date.init)

        var capturedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save(uniqueImagesFeed().models, completion: { (error) in
            capturedResults.append(error)
        })
        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssert(capturedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionError_afterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy.init()
        var sut: LocalFeedLoader? = LocalFeedLoader.init(store: store, timestampProvider: Date.init)

        var capturedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save(uniqueImagesFeed().models, completion: { (error) in
            capturedResults.append(error)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssert(capturedResults.isEmpty)
    }

    // MARK: Private methods

    private func makeSUT(timestampProvider: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStoreSpy)
    {
        let store = FeedStoreSpy.init()
        let sut = LocalFeedLoader.init(store: store, timestampProvider: timestampProvider)
        self.trackForMemoryLeaks(store, file: file, line: line)
        self.trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWithError expectedError: NSError?,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        var capturedError: Error?
        let exp = self.expectation(description: "Wait for save completion")
        sut.save(uniqueImagesFeed().models) { saveResult in
            if case let Result.failure(error) = saveResult {
                capturedError = error
            }
            exp.fulfill()
        }

        action()

        self.wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(capturedError as NSError?, expectedError)
    }

}
