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