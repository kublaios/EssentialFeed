//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Kubilay Erdogan on 2021-03-11.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        self.setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        self.deleteTestSpecificStoreArtifacts()
    }

    func test_load_deliversNoItemstOnEmptyCache() {
        let sut = self.makeSUT()

        self.expect(sut, toLoad: [])
    }

    func test_load_deliversSavedItemsOnSeparateInstance() {
        let sutToSave = self.makeSUT()
        let sutToLoad = self.makeSUT()
        let feed = uniqueImagesFeed().models

        self.save(feed, with: sutToSave)

        self.expect(sutToLoad, toLoad: feed)
    }

    func test_load_deliversOverriddenItems() {
        let sutToSave = self.makeSUT()
        let sutToOverride = self.makeSUT()
        let sutToLoad = self.makeSUT()
        let firstFeed = uniqueImagesFeed().models
        let latestFeed = uniqueImagesFeed().models

        self.save(firstFeed, with: sutToSave)
        self.save(latestFeed, with: sutToOverride)

        self.expect(sutToLoad, toLoad: latestFeed)
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let bundle = Bundle.init(for: CoreDataFeedStore.self)
        let storeURL = self.testSpecificStoreURL()
        let store = try! CoreDataFeedStore.init(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader.init(store: store, timestampProvider: Date.init)
        self.trackForMemoryLeaks(store, file: file, line: line)
        self.trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: LocalFeedLoader, toLoad feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = self.expectation(description: "Waiting for feed loader to load")
        sut.load { (result) in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, feed, file: file, line: line)
            default:
                XCTFail("Expected feed loader to load items, received \(result) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)
    }

    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = self.expectation(description: "Waiting for feed loader to save")
        sut.save(feed) { (saveResult) in
            if case let Result.failure(error) = saveResult {
                XCTFail("Expected feed loader to save successfully, received \(error) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)
    }

    private func setupEmptyStoreState() {
        self.deleteTestSpecificStoreArtifacts()
    }

    private func clearStoreSideEffects() {
        self.deleteTestSpecificStoreArtifacts()
    }

    private func deleteTestSpecificStoreArtifacts() {
        try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        return self.cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
