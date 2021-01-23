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
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient.init()

    var requestedURL: URL?

    private init() { }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        let _ = RemoteFeedLoader.init()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader.init()
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }

}
