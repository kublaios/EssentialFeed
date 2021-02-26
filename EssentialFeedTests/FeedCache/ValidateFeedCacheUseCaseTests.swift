//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-24.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.requestedCommands, [])
    }

    func test_validateCache_deletesCache_onRetrievalError() {
        let (sut, store) = self.makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.requestedCommands, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteEmptyCache() {
        let (sut, store) = self.makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.requestedCommands, [.retrieve])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let feed = uniqueImagesFeed()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = self.makeSUT(timestampProvider: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.requestedCommands, [.retrieve])
    }

    func test_validateCache_deletesExpiringCache() {
        let fixedCurrentDate = Date()
        let feed = uniqueImagesFeed()
        let expiringTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = self.makeSUT(timestampProvider: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: expiringTimestamp)

        XCTAssertEqual(store.requestedCommands, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_deletesExpiredCache() {
        let fixedCurrentDate = Date()
        let feed = uniqueImagesFeed()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = self.makeSUT(timestampProvider: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.requestedCommands, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteCacheAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy.init()
        var sut: LocalFeedLoader? = LocalFeedLoader.init(store: store, timestampProvider: Date.init)

        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.requestedCommands, [.retrieve])
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

}
