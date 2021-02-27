//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversErrorOnRetrievalFailure(on sut: FeedStore) {
        self.expect(sut, toRetrieve: .error(anyNSError()))
    }

    func assertThatRetrieveDeliversFailureOnRetrievalErrorWithoutSideEffects(on sut: FeedStore) {
        self.expect(sut, toRetrieveTwice: .error(anyNSError()))
    }
}
