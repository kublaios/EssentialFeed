//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_deliversEmptyResultOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.retrieve { (retrievalResult) in
            switch retrievalResult {
            case .empty:
                break
            default:
                XCTFail("Expected empty cache, received \(retrievalResult) instead.")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
    }

}
