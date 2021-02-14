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

    func save(_ items: [FeedItem]) {
        self.store.deleteCachedFeed { [unowned self] (error) in
            if error == nil {
                self.store.cache(items, timestamp: self.timestampProvider())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    var deleteCachedFeedCallCount = 0
    var deletionCompletions: [DeletionCompletion] = []
    var cacheFeedCallCount = 0
    var insertions: [(items: [FeedItem], timestamp: Date)] = []

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.deleteCachedFeedCallCount += 1
        self.deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        self.deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        self.deletionCompletions[index](nil)
    }

    func cache(_ items: [FeedItem], timestamp: Date) {
        self.cacheFeedCallCount += 1
        self.insertions.append((items, timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCache_uponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let (sut, store) = self.makeSUT()
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertion_onDeletionError() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let (sut, store) = self.makeSUT()
        let deletionError = self.anyNSError()

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.cacheFeedCallCount, 0)
    }

    func test_save_requestsInsertion_onSuccessfulDeletion() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let (sut, store) = self.makeSUT()

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.cacheFeedCallCount, 1)
    }

    func test_save_requestsInsertionWithTimestamp_onSuccessfulDeletion() {
        let items = [self.uniqueItem(), self.uniqueItem()]
        let timestamp = Date()
        let (sut, store) = self.makeSUT(timestampProvider: { timestamp })

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    // MARK: Private methods

    private func makeSUT(timestampProvider: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStore)
    {
        let store = FeedStore.init()
        let sut = LocalFeedLoader.init(store: store, timestampProvider: timestampProvider)
        self.trackForMemoryLeak(store, file: file, line: line)
        self.trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
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
