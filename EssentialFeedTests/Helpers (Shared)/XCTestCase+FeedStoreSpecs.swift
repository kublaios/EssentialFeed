//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyResultOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (expectedFeed, expectedTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((expectedFeed, expectedTimestamp), using: sut)

        self.expect(sut, toRetrieve: .found(feed: expectedFeed, timestamp: expectedTimestamp), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsAfterInsertingToEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (expectedFeed, expectedTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((expectedFeed, expectedTimestamp), using: sut)

        self.expect(sut, toRetrieveTwice: .found(feed: expectedFeed, timestamp: expectedTimestamp), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (feed, timestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((feed, timestamp), using: sut)

        XCTAssertNil(insertionError, "Cache insertion failed with \(insertionError!.localizedDescription)", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (feed, timestamp) = (uniqueImagesFeed().local, Date())
        self.insert((feed, timestamp), using: sut)

        let insertionError = self.insert((uniqueImagesFeed().local, Date()), using: sut)

        XCTAssertNil(insertionError, "Cache insertion failed with \(insertionError!.localizedDescription)", file: file, line: line)
    }

    func assertThatInsertUponNonEmptyCacheOverridesCacheWithoutSideEffects(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.insert((uniqueImagesFeed().local, Date()), using: sut)

        let (latestFeed, latestTimestamp) = (uniqueImagesFeed().local, Date())
        self.insert((latestFeed, latestTimestamp), using: sut)

        self.expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }

    func assertThatDeleteEmtpyCacheCompletesWithoutError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = self.deleteCache(using: sut)

        XCTAssertNil(deletionError, "Deleting empty cache failed with \(deletionError!.localizedDescription)", file: file, line: line)
    }

    func assertThatDeleteEmtpyCacheHasNoSideEffects(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.deleteCache(using: sut)

        self.expect(sut, toRetrieve: .empty)
    }

    func assertThatDeleteNonEmptyCacheDeletesExistingCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.insert((uniqueImagesFeed().local, Date()), using: sut)
        let deletionError = self.deleteCache(using: sut)

        XCTAssertNil(deletionError, "Deleting existing cache failed with \(deletionError!.localizedDescription)", file: file, line: line)
    }

    func assertThatDeleteNonEmptyCacheDeletesExistingCacheWithoutSideEffects(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.insert((uniqueImagesFeed().local, Date()), using: sut)
        self.deleteCache(using: sut)

        self.expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var operations: [XCTestExpectation] = []

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

        XCTAssertEqual(operations, [op1, op2, op3], file: file, line: line)
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (expectedFeed: [LocalFeedImage], expectedTimestamp: Date), using sut: FeedStore)
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

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
                file: StaticString = #filePath,
                line: UInt = #line)
    {
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
        self.expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore,
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

    @discardableResult
    func deleteCache(using sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        var deletionError: Error?
        let exp = self.expectation(description: "Waiting for cache deletion")
        sut.deleteCachedFeed { (capturedError) in
            deletionError = capturedError
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)

        return deletionError
    }
}
