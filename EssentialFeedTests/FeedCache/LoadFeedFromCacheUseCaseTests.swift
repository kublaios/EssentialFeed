//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-22.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.requestedCommands, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = self.makeSUT()

        sut.load()

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
        self.trackForMemoryLeak(store, file: file, line: line)
        self.trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }

}
