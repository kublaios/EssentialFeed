//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient.init()

    func get(from url: URL) { }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    override func get(from url: URL) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy.init()
        HTTPClient.shared = client
        let _ = RemoteFeedLoader.init()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy.init()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader.init()
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
