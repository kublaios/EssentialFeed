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

    func test_load_deliversSavedItemsOnSeparateInstance() {
        let sutToSave = self.makeSUT()
        let sutToLoad = self.makeSUT()
        let feed = uniqueImagesFeed().models

        let expSave = self.expectation(description: "Waiting for feed loader to save")
        sutToSave.save(feed) { (saveError) in
            XCTAssertNil(saveError, "Expected feed loader to save successfully.")
            expSave.fulfill()
        }
        self.wait(for: [expSave], timeout: 1.0)

        let expLoad = self.expectation(description: "Waiting for feed loader to load")
        sutToLoad.load { (loadResult) in
            switch loadResult {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, feed)
            default:
                XCTFail("Expected feed loader to load items, received \(loadResult) instead.")
            }
            expLoad.fulfill()
        }
        self.wait(for: [expLoad], timeout: 1.0)
    }

    func test_load_deliversOverriddenItems() {
        let sutToSave = self.makeSUT()
        let sutToOverride = self.makeSUT()
        let sutToLoad = self.makeSUT()
        let firstFeed = uniqueImagesFeed().models
        let latestFeed = uniqueImagesFeed().models

        let expSave = self.expectation(description: "Waiting for feed loader to save")
        sutToSave.save(firstFeed) { (saveError) in
            XCTAssertNil(saveError, "Expected feed loader to save successfully.")
            expSave.fulfill()
        }
        self.wait(for: [expSave], timeout: 1.0)

        let expOverride = self.expectation(description: "Waiting for feed loader to override")
        sutToOverride.save(latestFeed) { (overrideError) in
            XCTAssertNil(overrideError, "Expected feed loader to override successfully.")
            expOverride.fulfill()
        }
        self.wait(for: [expOverride], timeout: 1.0)

        let expLoad = self.expectation(description: "Waiting for feed loader to load")
        sutToLoad.load { (loadResult) in
            switch loadResult {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, latestFeed)
            default:
                XCTFail("Expected feed loader to load items, received \(loadResult) instead.")
            }
            expLoad.fulfill()
        }
        self.wait(for: [expLoad], timeout: 1.0)
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
