//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-26.
//

import XCTest
import EssentialFeed

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

    func test_insert_uponNonEmptyCache_overridesCache() {
        let sut = self.makeSUT()

        let (oldFeed, oldTimestamp) = (uniqueImagesFeed().local, Date())
        let firstInsertionError = self.insert((oldFeed, oldTimestamp), using: sut)
        XCTAssertNil(firstInsertionError, "Cache insertion failed with \(firstInsertionError!.localizedDescription)")

        let (latestFeed, latestTimestamp) = (uniqueImagesFeed().local, Date())
        let secondInsertionError = self.insert((latestFeed, latestTimestamp), using: sut)
        XCTAssertNil(secondInsertionError, "Overriding cache failed with \(secondInsertionError!.localizedDescription)")

        self.expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversError_onInsertionFailure() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = self.makeSUT(storeURL: invalidStoreURL)
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        XCTAssertNotNil(insertionError, "Expected insertion error, received no error instead")
        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_emtpyCache_hasNoSideEffects() {
        let sut = self.makeSUT()

        let deletionError = self.deleteCache(using: sut)
        XCTAssertNil(deletionError, "Deleting empty cache failed with \(deletionError!.localizedDescription)")
        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_nonEmptyCache_deletesExistingCache() {
        let sut = self.makeSUT()

        self.insert((uniqueImagesFeed().local, Date()), using: sut)

        let deletionError = self.deleteCache(using: sut)
        XCTAssertNil(deletionError, "Deleting existing cache failed with \(deletionError!.localizedDescription)")
        self.expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversError_onDeletionFailure() {
        let noDeletePermissionURL = self.documentsDirectoryURL()
        let sut = self.makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = self.deleteCache(using: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error, received no error instead")
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

    @discardableResult
    private func insert(_ cache: (expectedFeed: [LocalFeedImage], expectedTimestamp: Date), using sut: FeedStore)
    -> Error? {
        let exp = self.expectation(description: "Wait for insertion to FeedStore")
        var capturedError: Error?
        sut.insertCache(cache.expectedFeed, timestamp: cache.expectedTimestamp) { (insertionError) in
            capturedError = insertionError
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)

        return capturedError
    }

    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func expect(_ sut: FeedStore,
                        toRetrieve expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        let exp = self.expectation(description: "Wait for retrieval from FeedStore")

        sut.retrieve { (retrievalResult) in
            switch (retrievalResult, expectedResult) {
            case (.empty, .empty),
                 (.error, .error):
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

    private func deleteCache(using sut: FeedStore,
                             file: StaticString = #filePath,
                             line: UInt = #line)
    -> Error?
    {
        var deletionError: Error?
        let exp = self.expectation(description: "Waiting for cache deletion")
        sut.deleteCachedFeed { (capturedError) in
            deletionError = capturedError
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)

        return deletionError
    }

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
