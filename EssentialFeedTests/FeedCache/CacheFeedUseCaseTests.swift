//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    let timestampProvider: () -> Date

    init(store: FeedStore, timestampProvider: @escaping () -> Date) {
        self.store = store
        self.timestampProvider = timestampProvider
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        self.store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.store.insertCache(items, timestamp: self.timestampProvider()) { [weak self] (error) in
                    guard self != nil else { return }
                    completion(error)
                }
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCache(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

class FeedStoreSpy: FeedStore {

    enum RequestedCommand: Equatable {
        case deleteCachedFeed
        case insertCache([FeedItem], Date)
    }

    var deletionCompletions: [DeletionCompletion] = []
    var insertionCompletions: [InsertionCompletion] = []
    var cacheInsertions: [(items: [FeedItem], timestamp: Date)] = []
    private(set) var requestedCommands: [RequestedCommand] = []

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.deletionCompletions.append(completion)
        self.requestedCommands.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        self.deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        self.deletionCompletions[index](nil)
    }

    func insertCache(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        self.insertionCompletions.append(completion)
        self.cacheInsertions.append((items, timestamp))
        self.requestedCommands.append(.insertCache(items, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        self.insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        self.insertionCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCache_uponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.requestedCommands, [])
    }

    func test_save_requestsCacheDeletion() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let (sut, store) = self.makeSUT()
        sut.save(items) { _ in }
        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertion_onDeletionError() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let (sut, store) = self.makeSUT()
        let deletionError = self.anyNSError()

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed])
    }

    func test_save_requestsInsertionWithTimestamp_onSuccessfulDeletion() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let timestamp = Date()
        let (sut, store) = self.makeSUT(timestampProvider: { timestamp })

        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.requestedCommands, [.deleteCachedFeed, .insertCache(items, timestamp)])
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

        var capturedResults: [Error?] = []
        sut?.save([self.uniqueItem()], completion: { (error) in
            capturedResults.append(error)
        })
        sut = nil
        store.completeDeletion(with: self.anyNSError())

        XCTAssert(capturedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionError_afterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy.init()
        var sut: LocalFeedLoader? = LocalFeedLoader.init(store: store, timestampProvider: Date.init)

        var capturedResults: [Error?] = []
        sut?.save([self.uniqueItem()], completion: { (error) in
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
        sut.save([self.uniqueItem()]) { error in
            capturedError = error
            exp.fulfill()
        }

        action()

        self.wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(capturedError as NSError?, expectedError)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "a-desc", location: "a-loc", imageURL: self.anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError.init(domain: "any-error", code: 0)
    }

}
