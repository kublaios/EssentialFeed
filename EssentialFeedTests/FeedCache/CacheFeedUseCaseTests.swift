//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) { }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore.init()
        let _ = LocalFeedLoader.init(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
