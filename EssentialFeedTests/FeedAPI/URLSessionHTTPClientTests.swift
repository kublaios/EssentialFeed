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

    init(session: URLSession = .shared) {
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

    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }

    func test_getFromURL_deliversFailureOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let expectedError = NSError(domain: "an-error", code: 1)
        let sut = URLSessionHTTPClient.init()

        let exp = self.expectation(description: "Wait for get(from:) completion")
        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)
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

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?

    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        Self.stub = Stub(data: data, response: response, error: error)
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(Self.self)
        self.stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return Self.stub != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let data = Self.stub?.data {
            self.client?.urlProtocol(self, didLoad: data)
        }
        if let response = Self.stub?.response {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let e = Self.stub?.error {
            self.client?.urlProtocol(self, didFailWithError: e)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }

}
