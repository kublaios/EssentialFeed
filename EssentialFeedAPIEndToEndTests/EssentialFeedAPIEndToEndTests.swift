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
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient.init()
        let sut = RemoteFeedLoader.init(url: url, client: client)

        var capturedResult: LoadFeedResult?
        let exp = self.expectation(description: "Wait for RemoteFeedLoader to load")
        sut.load { (result) in
            capturedResult = result
            exp.fulfill()
        }

        self.wait(for: [exp], timeout: 5.0)

        switch capturedResult {
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Waiting for 8 items, received \(items.count) instead")
            XCTAssertEqual(items[0], self.item(at: 0), "Unexpected item at index \(0)")
            XCTAssertEqual(items[1], self.item(at: 1), "Unexpected item at index \(1)")
            XCTAssertEqual(items[2], self.item(at: 2), "Unexpected item at index \(2)")
            XCTAssertEqual(items[3], self.item(at: 3), "Unexpected item at index \(3)")
            XCTAssertEqual(items[4], self.item(at: 4), "Unexpected item at index \(4)")
            XCTAssertEqual(items[5], self.item(at: 5), "Unexpected item at index \(5)")
            XCTAssertEqual(items[6], self.item(at: 6), "Unexpected item at index \(6)")
            XCTAssertEqual(items[7], self.item(at: 7), "Unexpected item at index \(7)")
        case .failure(let error):
            XCTFail("Expected feed items, received \(error) instead")
        default:
            XCTFail("Expected feed items, received no response instead")
        }
    }

    private func item(at index: Int) -> FeedItem {
        return FeedItem(id: self.id(at: index),
                        description: self.description(at: index),
                        location: self.location(at: index),
                        imageURL: self.imageURL(at: index))
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

    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }

}
