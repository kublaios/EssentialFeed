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

    func test_getFromURL_deliversFailureOnRequestError() {

        URLProtocolStub.startInterceptingRequests()

        let url = URL(string: "https://a-url.com")!
        let expectedError = NSError(domain: "an-error", code: 1)
        let sut = URLSessionHTTPClient.init()

        let exp = self.expectation(description: "Wait for get(from:) completion")
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: expectedError)
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

        URLProtocolStub.stopInterceptingRequests()
    }

}

private class URLProtocolStub: URLProtocol {
    private static var stubs: [URL: Stub] = [:]

    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error? = nil) {
        Self.stubs[url] = Stub(data: data, response: response, error: error)
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(Self.self)
        self.stubs.removeAll()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url
        else { return false }

        return Self.stubs[url] != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = self.request.url,
              let stub = Self.stubs[url]
        else { return }

        if let e = stub.error {
            self.client?.urlProtocol(self, didFailWithError: e)
        } else if let response = stub.response {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }

}
