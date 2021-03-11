//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        XCTAssertNotNil(insertionError, "Expected insertion error, received no error instead", file: file, line: line)
    }

    func assertThatInsertDeliversErrorOnInsertionFailureWithoutSideEffects(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        self.expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
