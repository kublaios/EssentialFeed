//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = self.makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = self.makeSUT(url: url)
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = self.makeSUT(url: url)
        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = self.makeSUT()

        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load() { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!)
    -> (sut: RemoteFeedLoader, client: HTTPClientSpy)
    {
        let client = HTTPClientSpy.init()
        return (RemoteFeedLoader.init(url: url, client: client), client)
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (Error) -> Void)] = []
        var requestedURLs: [URL] {
            return self.messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.messages.append((url, completion))
        }

        func complete(with error: Error, atCompletionBlock index: Int = 0) {
            self.messages[index].completion(error)
        }
    }

}
