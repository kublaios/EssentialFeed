//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-29.
//

import Foundation
import XCTest

// Production code
class URLSessionHTTPClient {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        self.session.dataTask(with: url)
    }
}
// ---

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy.init()
        let sut = URLSessionHTTPClient.init(session: session)

        sut.get(from: url)

        XCTAssertEqual(session.receivedURLs, [url])
    }

}

class URLSessionSpy: URLSession {
    var receivedURLs: [URL] = []
    override init() { }
    override func dataTask(with url: URL) -> URLSessionDataTask {
        self.receivedURLs.append(url)
        return FakeURLSessionDataTask.init()
    }
}

class FakeURLSessionDataTask: URLSessionDataTask {
    override init() { }
}
