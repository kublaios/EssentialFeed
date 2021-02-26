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
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return self.feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }

        var local: LocalFeedImage {
            return LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
        }
    }

    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: self.storeURL)
        else { return completion(.empty) }

        let decoder = JSONDecoder.init()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
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
        let sut = self.makeSUT()
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
        let sut = self.makeSUT()
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
        let sut = self.makeSUT()
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

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }

}
