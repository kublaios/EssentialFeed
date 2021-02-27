//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

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
