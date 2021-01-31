//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-29.
//

import XCTest
import EssentialFeed

// Production code
class URLSessionHTTPClient {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        self.session.dataTask(with: url) { (_, _, error) in
            if let e = error {
                completion(.failure(e))
            }
        }.resume()
    }
}
// ---

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskOnCreationOnlyOnce() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy.init()
        let task = URLSessionDataTaskSpy.init()
        let sut = URLSessionHTTPClient.init(session: session)

        session.stub(url: url, task: task)
        sut.get(from: url, completion: { _ in })

        XCTAssertEqual(task.resumeCallCount, 1)
    }


    func test_getFromURL_deliversFailureOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let expectedError = NSError(domain: "an-error", code: 1)
        let task = URLSessionDataTaskSpy.init()
        let session = URLSessionSpy.init()
        let sut = URLSessionHTTPClient.init(session: session)

        let exp = self.expectation(description: "Wait for get(from:) completion")
        session.stub(url: url, task: task, error: expectedError)
        sut.get(from: url) { (result) in
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error, expectedError)
            default:
                XCTFail("Expected failure with error \(expectedError), received \(result) instead")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
    }

}

class URLSessionSpy: URLSession {
    var stubs: [URL: Stub] = [:]

    struct Stub {
        let task: URLSessionDataTask
        let error: Error?
    }

    override init() { }

    func stub(url: URL, task: URLSessionDataTask, error: Error? = nil) {
        self.stubs[url] = Stub(task: task, error: error)
    }

    override func dataTask(with url: URL,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask
    {
        guard let stub = self.stubs[url]
        else {
            fatalError("Could not find Stub for \(url)")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
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
