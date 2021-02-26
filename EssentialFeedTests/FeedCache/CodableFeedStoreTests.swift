//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }

    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: self.storeURL)
        else { return completion(.empty) }

        let decoder = JSONDecoder.init()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }

    func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(feed: feed, timestamp: timestamp)
        let encoder = JSONEncoder.init()
        let data = try! encoder.encode(cache)
        try! data.write(to: self.storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_deliversEmptyResultOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.retrieve { (retrievalResult) in
            switch retrievalResult {
            case .empty:
                break
            default:
                XCTFail("Expected empty cache, received \(retrievalResult) instead.")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.retrieve { (firstResult) in
            sut.retrieve { (secondResult) in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, received \(firstResult), \(secondResult) instead.")
                }
                exp.fulfill()
            }
        }

        self.wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_afterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let (expectedFeed, expectedTimestamp) = (uniqueImagesFeed().local, Date())
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.insertCache(expectedFeed, timestamp: expectedTimestamp) { (insertionError) in
            XCTAssertNil(insertionError, "Expected cache insertion to succeed, failed with \(insertionError!.localizedDescription)")

            sut.retrieve { (retrievalResult) in
                switch retrievalResult {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(receivedFeed, expectedFeed)
                    XCTAssertEqual(receivedTimestamp, expectedTimestamp)
                default:
                    XCTFail("Cache retrieval after insertion failed with \(retrievalResult).")
                }
                exp.fulfill()
            }
        }

        self.wait(for: [exp], timeout: 1.0)
    }

}
