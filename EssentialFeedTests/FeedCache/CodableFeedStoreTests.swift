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

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

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

        self.setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        self.removeStoreSideEffects()
    }

    func test_deliversEmptyResultOnEmptyCache() {
        let sut = self.makeSUT()

        self.expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = self.makeSUT()

        self.expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValues_onNonEmptyCache() {
        let sut = self.makeSUT()
        let (expectedFeed, expectedTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((expectedFeed, expectedTimestamp), using: sut)

        self.expect(sut, toRetrieve: .found(feed: expectedFeed, timestamp: expectedTimestamp))
    }

    func test_retrieve_afterInsertingToEmptyCache_hasNoSideEffects() {
        let sut = self.makeSUT()
        let (expectedFeed, expectedTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((expectedFeed, expectedTimestamp), using: sut)

        self.expect(sut, toRetrieveTwice: .found(feed: expectedFeed, timestamp: expectedTimestamp))
    }

    // MARK: Private methods

    private func insert(_ cache: (expectedFeed: [LocalFeedImage], expectedTimestamp: Date), using sut: CodableFeedStore) {
        let exp = self.expectation(description: "Wait for insertion to CodableFeedStore")
        sut.insertCache(cache.expectedFeed, timestamp: cache.expectedTimestamp) { (insertionError) in
            XCTAssertNil(insertionError, "Expected cache insertion to succeed, failed with \(insertionError!.localizedDescription)")
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)
    }

    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func expect(_ sut: CodableFeedStore,
                        toRetrieve expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.retrieve { (retrievalResult) in
            switch (retrievalResult, expectedResult) {
            case (.empty, .empty):
                break
            case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected retrieval results to be the same, received \(retrievalResult) instead of \(expectedResult) instead.")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: self.testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func setupEmptyStoreState() {
        self.deleteStoreArtifacts()
    }

    private func removeStoreSideEffects() {
        self.deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

}
