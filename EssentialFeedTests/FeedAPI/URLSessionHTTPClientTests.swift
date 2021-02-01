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

    struct UnexpectedValuesRepresentation: Error { }

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        self.session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                completion(.failure(e))
            } else if let d = data, !d.isEmpty { // 204 can return no-data with valid HTTP code
            } else if let _ = response {
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
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

    func test_getFromURL_performsGETRequestWithURL() {
        let url = self.anyURL()
        let sut = self.makeSUT()

        let exp = self.expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }

        self.wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_deliversFailureOnRequestError() {
        let expectedError = self.anyNSError()
        let receivedError = self.resultErrorFor(data: nil, response: nil, error: expectedError)
        XCTAssertEqual(expectedError, receivedError as NSError?)
    }

    func test_getFromURL_failsWhenAllValuesAreNil() {
        XCTAssertNotNil(self.resultErrorFor(data: nil, response: nil, error: nil))
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient.init()
        self.trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "an-error", code: 1)
    }

    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error expectedError: NSError?,
                                file: StaticString = #filePath,
                                line: UInt = #line)
    -> Error?
    {
        let url = self.anyURL()
        let sut = self.makeSUT(file: file, line: line)

        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)
        var capturedError: Error?
        let exp = self.expectation(description: "Wait for get(from:) completion")
        sut.get(from: url) { (result) in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
        return capturedError
    }

}

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        Self.stub = Stub(data: data, response: response, error: error)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        Self.requestObserver = observer
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(Self.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(Self.self)
        Self.stub = nil
        Self.requestObserver = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        Self.requestObserver?(request)
        return true
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
