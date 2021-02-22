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
        let feed = self.uniqueImagesFeed().models
        let (sut, store) = self.makeSUT()
        sut.save(feed) { _ in }
        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertion_onDeletionError() {
        let feed = self.uniqueImagesFeed().models
        let (sut, store) = self.makeSUT()
        let deletionError = self.anyNSError()

        sut.save(feed) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_requestsInsertionWithTimestamp_onSuccessfulDeletion() {
        let (feed, localFeed) = self.uniqueImagesFeed()
        let timestamp = Date()
        let (sut, store) = self.makeSUT(timestampProvider: { timestamp })

        sut.save(feed) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed, .insertCache(localFeed, timestamp)])
    }

    func test_save_fails_onDeletionError() {
        let (sut, store) = self.makeSUT()
        let deletionError = self.anyNSError()
        self.expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_fails_onInsertionError() {
        let (sut, store) = self.makeSUT()
        let insertionError = self.anyNSError()
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
        sut?.save(self.uniqueImagesFeed().models, completion: { (error) in
            capturedResults.append(error)
        })
        sut = nil
        store.completeDeletion(with: self.anyNSError())

        XCTAssert(capturedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionError_afterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy.init()
        var sut: LocalFeedLoader? = LocalFeedLoader.init(store: store, timestampProvider: Date.init)

        var capturedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save(self.uniqueImagesFeed().models, completion: { (error) in
            capturedResults.append(error)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: self.anyNSError())

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
        self.trackForMemoryLeak(store, file: file, line: line)
        self.trackForMemoryLeak(sut, file: file, line: line)
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
        sut.save(self.uniqueImagesFeed().models) { error in
            capturedError = error
            exp.fulfill()
        }

        action()

        self.wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(capturedError as NSError?, expectedError)
    }

    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "a-desc", location: "a-loc", url: self.anyURL())
    }

    private func uniqueImagesFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [self.uniqueImage(), self.uniqueImage()]
        let localImages = models.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
        return (models, localImages)
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError.init(domain: "any-error", code: 0)
    }

}
