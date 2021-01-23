//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        self.client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy.init()
        let _ = RemoteFeedLoader.init(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy.init()
        let sut = RemoteFeedLoader.init(client: client)
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
