//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-22.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = self.makeSUT()
        XCTAssertEqual(store.requestedCommands, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = self.makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.requestedCommands, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = self.makeSUT()
        let retrievalError = self.anyNSError()
        let exp = self.expectation(description: "failsOnRetrievalError waiting for LocalFeedLoader.load")

        var receivedError: Error?
        sut.load { (result) in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("failsOnRetrievalError expects \(retrievalError), received \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)
        self.wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    // MARK: Private methods

    private func makeSUT(timestampProvider: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStoreSpy)
    {
        let store = FeedStoreSpy.init()
        let sut = LocalFeedLoader.init(store: store, timestampProvider: timestampProvider)
        self.trackForMemoryLeak(store, file: file, line: line)
        self.trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        return NSError.init(domain: "any-error", code: 0)
    }

}
