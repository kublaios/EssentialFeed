//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-26.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

    override func setUp() {
        super.setUp()

        self.setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        self.removeStoreSideEffects()
    }

    func test_retrieve_deliversEmptyResultOnEmptyCache() {
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

    func test_retrieve_deliversError_onRetrievalFailure() {
        let storeURL = self.testSpecificStoreURL()
        let sut = self.makeSUT(storeURL: storeURL)

        try? "invalid-json".data(using: .utf8)?.write(to: storeURL)

        self.expect(sut, toRetrieve: .error(anyNSError()))
    }

    func test_retrieve_deliversFailure_onRetrievalError_withoutSideEffects() {
        let storeURL = self.testSpecificStoreURL()
        let sut = self.makeSUT(storeURL: storeURL)

        try? "invalid-json".data(using: .utf8)?.write(to: storeURL)

        self.expect(sut, toRetrieveTwice: .error(anyNSError()))
    }

    func test_insert_deliversNoError_onEmptyCache() {
        let sut = self.makeSUT()
        let (feed, timestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((feed, timestamp), using: sut)

        XCTAssertNil(insertionError, "Cache insertion failed with \(insertionError!.localizedDescription)")
    }

    func test_insert_deliversNoError_onNonEmptyCache() {
        let sut = self.makeSUT()

        let (feed, timestamp) = (uniqueImagesFeed().local, Date())
        self.insert((feed, timestamp), using: sut)

        let insertionError = self.insert((uniqueImagesFeed().local, Date()), using: sut)

        XCTAssertNil(insertionError, "Cache insertion failed with \(insertionError!.localizedDescription)")
    }

    func test_insert_uponNonEmptyCache_overridesCache_withoutSideEffects() {
        let sut = self.makeSUT()

        self.insert((uniqueImagesFeed().local, Date()), using: sut)

        let (latestFeed, latestTimestamp) = (uniqueImagesFeed().local, Date())
        self.insert((latestFeed, latestTimestamp), using: sut)

        self.expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversError_onInsertionFailure() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = self.makeSUT(storeURL: invalidStoreURL)
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        XCTAssertNotNil(insertionError, "Expected insertion error, received no error instead")
    }

    func test_insert_deliversError_onInsertionFailure_withoutSideEffects() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = self.makeSUT(storeURL: invalidStoreURL)
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_emtpyCache_completesWithoutError() {
        let sut = self.makeSUT()

        let deletionError = self.deleteCache(using: sut)

        XCTAssertNil(deletionError, "Deleting empty cache failed with \(deletionError!.localizedDescription)")
    }

    func test_delete_emtpyCache_hasNoSideEffects() {
        let sut = self.makeSUT()

        self.deleteCache(using: sut)

        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_nonEmptyCache_deletesExistingCache() {
        let sut = self.makeSUT()

        self.insert((uniqueImagesFeed().local, Date()), using: sut)
        let deletionError = self.deleteCache(using: sut)

        XCTAssertNil(deletionError, "Deleting existing cache failed with \(deletionError!.localizedDescription)")
    }

    func test_delete_nonEmptyCache_deletesExistingCache_withoutSideEffects() {
        let sut = self.makeSUT()

        self.insert((uniqueImagesFeed().local, Date()), using: sut)
        self.deleteCache(using: sut)

        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversError_onDeletionFailure() {
        let noDeletePermissionURL = self.documentsDirectoryURL()
        let sut = self.makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = self.deleteCache(using: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error, received no error instead")
    }

    func test_delete_deliversError_onDeletionFailure_withoutSideEffects() {
        let noDeletePermissionURL = self.documentsDirectoryURL()
        let sut = self.makeSUT(storeURL: noDeletePermissionURL)

        self.deleteCache(using: sut)
        self.expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        var operations: [XCTestExpectation] = []
        let sut = self.makeSUT()

        let op1 = self.expectation(description: "Operation 1")
        sut.insertCache(uniqueImagesFeed().local, timestamp: Date(), completion: { (_) in
            operations.append(op1)
            op1.fulfill()
        })

        let op2 = self.expectation(description: "Operation 2")
        sut.deleteCachedFeed { (_) in
            operations.append(op2)
            op2.fulfill()
        }

        let op3 = self.expectation(description: "Operation 3")
        sut.insertCache(uniqueImagesFeed().local, timestamp: Date(), completion: { (_) in
            operations.append(op3)
            op3.fulfill()
        })

        self.wait(for: [op1, op2, op3], timeout: 5.0)

        XCTAssertEqual(operations, [op1, op2, op3])
    }

    // MARK: Private methods

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? self.testSpecificStoreURL())
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

    private func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

}
