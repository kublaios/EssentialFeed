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

        self.expect(sut, toCompleteWithResult: self.failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = self.makeSUT()

        let sampleCodes = [199, 201, 400, 500]
        sampleCodes.enumerated().forEach { (index, code) in
            self.expect(sut, toCompleteWithResult: self.failure(.invalidData), when: {
                let jsonData = self.makeFeedItemsJSON(itemJSONs: [])
                client.complete(withStatusCode: code, data: jsonData, atCompletionBlock: index)
            })
        }
    }

    func test_load_deliversInvalidDataErrorOn200HTTPResponse() {
        let (sut, client) = self.makeSUT()

        self.expect(sut, toCompleteWithResult: self.failure(.invalidData), when: {
            let jsonData = "invalid json".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: jsonData)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = self.makeSUT()

        self.expect(sut, toCompleteWithResult: .success([])) {
            let jsonData = self.makeFeedItemsJSON(itemJSONs: [])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }

    func test_load_deliversItemsArrayOn200HTTPResponseWithItemsJSON() {
        let (sut, client) = self.makeSUT()

        let item1 = self.makeFeedItem(id: UUID(), imageURL: URL(string: "https://an-image-url.com")!)
        let item2 = self.makeFeedItem(id: UUID(),
                                      description: "a description",
                                      location: "a location",
                                      imageURL: URL(string: "https://another-image-url.com")!)

        self.expect(sut, toCompleteWithResult: .success([item1.item, item2.item])) {
            let jsonData = self.makeFeedItemsJSON(itemJSONs: [item1.itemJSON, item2.itemJSON])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }

    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy.init()
        var sut: RemoteFeedLoader? = RemoteFeedLoader.init(url: url, client: client)

        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.load() { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: self.makeFeedItemsJSON(itemJSONs: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line)
    -> (sut: RemoteFeedLoader, client: HTTPClientSpy)
    {
        let client = HTTPClientSpy.init()
        let sut = RemoteFeedLoader.init(url: url, client: client)
        self.trackForMemoryLeak(sut, file: file, line: line)
        self.trackForMemoryLeak(client, file: file, line: line)
        return (sut, client)
    }

    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        self.addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,
                         "Instance should have been deallocated. Potential memory leak!",
                         file: file,
                         line: line)
        }
    }

    private func makeFeedItem(id: UUID,
                              description: String? = nil,
                              location: String? = nil,
                              imageURL: URL)
    -> (item: FeedItem, itemJSON: [String: Any])
    {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString,
        ].reduce(into: [String: Any](), { (acc, el) in
            if (el.value != nil) { acc[el.key] = el.value }
        })
        return (item, itemJSON)
    }

    private func makeFeedItemsJSON(itemJSONs: [[String: Any]]) -> Data {
        let itemsJson = ["items": itemJSONs]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }

    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line)
    {
        let exp = self.expectation(description: "Waiting for `RemoteFeedLoader.load` to complete")

        sut.load { (receivedResult) in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        self.wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        var requestedURLs: [URL] {
            return self.messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            self.messages.append((url, completion))
        }

        func complete(with error: Error, atCompletionBlock index: Int = 0) {
            self.messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int,
                      data: Data,
                      atCompletionBlock index: Int = 0)
        {
            let response = HTTPURLResponse.init(url: self.messages[index].url,
                                                statusCode: code,
                                                httpVersion: nil,
                                                headerFields: nil)!
            self.messages[index].completion(.success(data, response))
        }

    }

}
