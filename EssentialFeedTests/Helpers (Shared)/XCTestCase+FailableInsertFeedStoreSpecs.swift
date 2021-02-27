//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionFailure(on sut: FeedStore) {
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        let insertionError = self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        XCTAssertNotNil(insertionError, "Expected insertion error, received no error instead")
    }

    func assertThatInsertDeliversErrorOnInsertionFailureWithoutSideEffects(on sut: FeedStore) {
        let (anyValidFeed, anyValidTimestamp) = (uniqueImagesFeed().local, Date())

        self.insert((anyValidFeed, anyValidTimestamp), using: sut)

        self.expect(sut, toRetrieve: .empty)
    }
}
