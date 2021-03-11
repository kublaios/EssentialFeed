//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-28.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversErrorOnRetrievalFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveDeliversFailureOnRetrievalErrorWithoutSideEffects(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        self.expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
