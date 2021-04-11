//
//  FeedUIIntegrationTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    func assertThat(_ sut: FeedViewController, rendersFeed feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedItems == feed.count
        else {
            return XCTFail("Expected \(feed.count) feed items, got \(sut.numberOfRenderedFeedItems) instead!", file: file, line: line)
        }

        feed.enumerated().forEach { [weak self] (index, image) in
            self?.assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard let imageView = sut.feedImageView(at: index) as? FeedImageCell
        else {
            return XCTFail("Expected feed image view at index \(index), received nil instead!", file: file, line: line)
        }

        XCTAssertEqual(imageView.isShowingLocation, image.location != nil, "Expected feed image view at index \(index) displaying image location to be \(image.location != nil)", file: file, line: line)
        XCTAssertEqual(imageView.locationText, image.location, "Expected feed image view at index \(index) displaying location text \(String(describing: image.location)), got \(String(describing: imageView.locationText)) instead", file: file, line: line)
        XCTAssertEqual(imageView.descriptionText, image.description, "Expected feed image view at index \(index) displaying description text \(String(describing: image.description)), got \(String(describing: imageView.descriptionText)) instead", file: file, line: line)
    }
}
