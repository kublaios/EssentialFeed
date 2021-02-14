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

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        self.store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var cacheFeedCallCount = 0

    func deleteCachedFeed() {
        self.deleteCachedFeedCallCount += 1
    }

    func completeDeletion(with error: Error, at index: Int = 0) {

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

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore.init()
        let sut = LocalFeedLoader.init(store: store)
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
