//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Kubilay Erdogan on 2021-03-11.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemstOnEmptyCache() {
        let sut = self.makeSUT()

        let exp = self.expectation(description: "Waiting for load completion")
        sut.load { (result) in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            default:
                XCTFail("Expected empty feed, received \(result) instead.")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
    }

    // MARK: Private methods

    private func makeSUT() -> LocalFeedLoader {
        let bundle = Bundle.init(for: CoreDataFeedStore.self)
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let storeURL = cachesDirectory.appendingPathComponent("\(type(of: self)).store")
        let store = try! CoreDataFeedStore.init(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader.init(store: store, timestampProvider: Date.init)
        self.trackForMemoryLeaks(store)
        self.trackForMemoryLeaks(sut)
        return sut
    }

}
