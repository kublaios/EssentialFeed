//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader { }

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.init()
        let _ = RemoteFeedLoader.init()

        XCTAssertNil(client.requestedURL)
    }

}
