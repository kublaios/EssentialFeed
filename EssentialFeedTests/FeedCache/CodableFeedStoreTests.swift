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

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = self.expectation(description: "Wait for retrieval from CodableFeedStore")

        sut.retrieve { (firstResult) in
            sut.retrieve { (secondResult) in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, received \(firstResult), \(secondResult) instead.")
                }
                exp.fulfill()
            }
        }

        self.wait(for: [exp], timeout: 1.0)
    }

}
