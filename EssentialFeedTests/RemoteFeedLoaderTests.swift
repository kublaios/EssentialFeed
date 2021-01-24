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
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = self.makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }

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

    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = self.makeSUT()

        let sampleCodes = [199, 201, 400, 500]
        sampleCodes.enumerated().forEach { (index, code) in
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load() { capturedErrors.append($0) }

            client.complete(withStatusCode: code, atCompletionBlock: index)

            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }

    func test_load_deliversInvalidDataErrorOn200HTTPResponse() {
        let (sut, client) = self.makeSUT()

        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load() { capturedErrors.append($0) }

        let jsonData = "invalid json".data(using: .utf8)!
        client.complete(withStatusCode: 200, data: jsonData)

        XCTAssertEqual(capturedErrors, [.invalidData])
    }

    // MARK: Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!)
    -> (sut: RemoteFeedLoader, client: HTTPClientSpy)
    {
        let client = HTTPClientSpy.init()
        return (RemoteFeedLoader.init(url: url, client: client), client)
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClientResponse) -> Void)] = []
        var requestedURLs: [URL] {
            return self.messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            self.messages.append((url, completion))
        }

        func complete(with error: Error, atCompletionBlock index: Int = 0) {
            self.messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int,
                      data: Data = Data(),atCompletionBlock index: Int = 0)
        {
            let response = HTTPURLResponse.init(url: self.messages[index].url,
                                                statusCode: code,
                                                httpVersion: nil,
                                                headerFields: nil)!
            self.messages[index].completion(.success(data, response))
        }

    }

}
