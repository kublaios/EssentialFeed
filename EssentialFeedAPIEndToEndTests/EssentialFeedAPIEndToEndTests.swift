//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Kubilay Erdogan on 2021-02-03.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndServerGETFeedResult_matchesFixedTestAccountData() {
        let capturedResult = self.getResult()
        switch capturedResult {
        case .success(let images):
            XCTAssertEqual(images.count, 8, "Waiting for 8 images, received \(images.count) instead")
            XCTAssertEqual(images[0], self.image(at: 0), "Unexpected image at index \(0)")
            XCTAssertEqual(images[1], self.image(at: 1), "Unexpected image at index \(1)")
            XCTAssertEqual(images[2], self.image(at: 2), "Unexpected image at index \(2)")
            XCTAssertEqual(images[3], self.image(at: 3), "Unexpected image at index \(3)")
            XCTAssertEqual(images[4], self.image(at: 4), "Unexpected image at index \(4)")
            XCTAssertEqual(images[5], self.image(at: 5), "Unexpected image at index \(5)")
            XCTAssertEqual(images[6], self.image(at: 6), "Unexpected image at index \(6)")
            XCTAssertEqual(images[7], self.image(at: 7), "Unexpected image at index \(7)")
        case .failure(let error):
            XCTFail("Expected feed images, received \(error) error instead")
        default:
            XCTFail("Expected feed images, received no response instead")
        }
    }

    private func getResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let session = URLSession.init(configuration: .ephemeral)
        let client = URLSessionHTTPClient.init(session: session)
        let sut = RemoteFeedLoader.init(url: url, client: client)

        self.trackForMemoryLeak(client, file: file, line: line)
        self.trackForMemoryLeak(sut, file: file, line: line)

        var capturedResult: LoadFeedResult?
        let exp = self.expectation(description: "Wait for RemoteFeedLoader to load")
        sut.load { (result) in
            capturedResult = result
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 5.0)
        return capturedResult
    }

    private func image(at index: Int) -> FeedImage {
        return FeedImage(id: self.id(at: index),
                         description: self.description(at: index),
                         location: self.location(at: index),
                         url: self.url(at: index))
    }

    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01",
        ][index])!
    }

    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }

    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }

    private func url(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }

}
