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
        self.session.dataTask(with: url).resume()
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

    func test_getFromURL_resumesDataTaskOnCreationOnlyOnce() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy.init()
        let task = URLSessionDataTaskSpy.init()
        let sut = URLSessionHTTPClient.init(session: session)

        session.stub(url: url, task: task)
        sut.get(from: url)

        XCTAssertEqual(task.resumeCallCount, 1)
    }

}

class URLSessionSpy: URLSession {
    var receivedURLs: [URL] = []
    var stubbedDataTasks: [URL: URLSessionDataTask] = [:]

    override init() { }

    func stub(url: URL, task: URLSessionDataTask) {
        self.stubbedDataTasks[url] = task
    }

    override func dataTask(with url: URL) -> URLSessionDataTask {
        self.receivedURLs.append(url)
        return self.stubbedDataTasks[url] ?? FakeURLSessionDataTask.init()
    }
}

class FakeURLSessionDataTask: URLSessionDataTask {
    override init() { }
}

class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount: Int = 0

    override init() { }

    override func resume() {
        self.resumeCallCount += 1
    }
}
