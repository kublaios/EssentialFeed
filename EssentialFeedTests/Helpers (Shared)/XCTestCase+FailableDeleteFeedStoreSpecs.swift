//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionFailure(on sut: FeedStore) {
        let deletionError = self.deleteCache(using: sut)

        XCTAssertNotNil(deletionError, "Expected deletion error, received no error instead")
    }

    func assertThatDeleteDeliversErrorOnDeletionFailureWithoutSideEffects(on sut: FeedStore) {
        self.deleteCache(using: sut)

        self.expect(sut, toRetrieve: .empty)
    }
}
