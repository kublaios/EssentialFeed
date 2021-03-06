//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-01-29.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let sut = self.makeSUT()

        let exp = self.expectation(description: "performsGETRequestWithURL wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }

        self.wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_deliversFailureOnRequestError() {
        let expectedError = anyNSError()
        let receivedError = self.resultErrorFor(data: nil, response: nil, error: expectedError)
        XCTAssertEqual(expectedError.domain, (receivedError as NSError?)?.domain)
        XCTAssertEqual(expectedError.code, (receivedError as NSError?)?.code)
    }

    func test_getFromURL_failsForAllInvalidCases() {
        XCTAssertNotNil(self.resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(self.resultErrorFor(data: nil, response: self.nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(self.resultErrorFor(data: self.anyData(), response: nil, error: nil))
        XCTAssertNotNil(self.resultErrorFor(data: self.anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(self.resultErrorFor(data: nil, response: self.nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(self.resultErrorFor(data: nil, response: self.anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(self.resultErrorFor(data: self.anyData(), response: self.nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(self.resultErrorFor(data: self.anyData(), response: self.anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(self.resultErrorFor(data: self.anyData(), response: self.nonHTTPURLResponse(), error: nil))
    }

    func test_getFromURL_deliversDataAndResponse() {
        let expectedData = self.anyData()
        let expectedResponse = self.anyHTTPURLResponse()
        let receivedValues = self.resultValuesFor(data: expectedData, response: expectedResponse, error: nil)

        XCTAssertEqual(receivedValues?.data, expectedData)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, expectedResponse.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataButValidResponse() {
        let expectedResponse = self.anyHTTPURLResponse()
        let receivedValues = self.resultValuesFor(data: nil, response: expectedResponse, error: nil)
        let emptyData = Data() // 204 response has empty data but valid status code

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, expectedResponse.statusCode)
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient.init()
        self.trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyData() -> Data {
        return Data("any-data".utf8)
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse.init(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse.init(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }

    private func resultValuesFor(data: Data?,
                                 response: URLResponse?,
                                 error: NSError?,
                                 file: StaticString = #filePath,
                                 line: UInt = #line)
    -> (data: Data, response: HTTPURLResponse)?
    {
        let result = self.resultFor(data: data, response: response, error: error)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            return nil
        }
    }

    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: NSError?,
                                file: StaticString = #filePath,
                                line: UInt = #line)
    -> Error?
    {
        let result = self.resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }

    private func resultFor(data: Data?,
                           response: URLResponse?,
                           error: NSError?,
                           file: StaticString = #filePath,
                           line: UInt = #line)
    -> HTTPClient.Result
    {
        let sut = self.makeSUT(file: file, line: line)
        var capturedResult: HTTPClient.Result!

        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = self.expectation(description: "Waiting for get(from:) completion")
        sut.get(from: anyURL()) { (result) in
            capturedResult = result
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 1.0)
        return capturedResult
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
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard Self.requestObserver == nil
        else {
            Self.requestObserver?(self.request)
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }

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
