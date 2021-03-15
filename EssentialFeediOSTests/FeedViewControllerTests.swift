//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = self.makeSUT()

        XCTAssertEqual(loader.loadCallCount, .zero, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingIndicator_isVisible_whenFeedIsLoading() {
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when the view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator when the feed is loaded for the first time")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when the feed is being loaded")

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator when the feed is loaded")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = self.makeImage(description: "a description", location: "a location")
        let image1 = self.makeImage(description: "a description", location: nil)
        let image2 = self.makeImage(description: nil, location: "a location")
        let image3 = self.makeImage(description: nil, location: nil)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        self.assertThat(sut, rendersFeed: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        self.assertThat(sut, rendersFeed: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        self.assertThat(sut, rendersFeed: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = self.makeImage(description: "a description", location: "a location")
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [image0], at: 0)
        self.assertThat(sut, rendersFeed: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        self.assertThat(sut, rendersFeed: [image0])
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, FeedLoaderSpy) {
        let loader = FeedLoaderSpy.init()
        let sut = FeedViewController.init(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func assertThat(_ sut: FeedViewController, rendersFeed feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedItems == feed.count
        else {
            return XCTFail("Expected \(feed.count) feed items, got \(sut.numberOfRenderedFeedItems) instead!", file: file, line: line)
        }

        feed.enumerated().forEach { [weak self] (index, image) in
            self?.assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard let imageView = sut.feedImageView(at: index) as? FeedImageCell
        else {
            return XCTFail("Expected feed image view at index \(index), received nil instead!", file: file, line: line)
        }

        XCTAssertEqual(imageView.isShowingLocation, image.location != nil, "Expected feed image view at index \(index) displaying image location to be \(image.location != nil)", file: file, line: line)
        XCTAssertEqual(imageView.locationText, image.location, "Expected feed image view at index \(index) displaying location text \(String(describing: image.location)), got \(String(describing: imageView.locationText)) instead", file: file, line: line)
        XCTAssertEqual(imageView.descriptionText, image.description, "Expected feed image view at index \(index) displaying description text \(String(describing: image.description)), got \(String(describing: imageView.descriptionText)) instead", file: file, line: line)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://any-url.com")!) -> FeedImage {
        return FeedImage.init(id: UUID(), description: description, location: location, url: url)
    }
}

private extension FeedViewControllerTests {
    class FeedLoaderSpy: FeedLoader {
        private(set) var completions: [(FeedLoader.Result) -> Void] = []

        var loadCallCount: Int  {
            return self.completions.count
        }

        init() { }

        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            self.completions.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            self.completions[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError.init(domain: "any-error", code: 0)
            self.completions[index](.failure(error))
        }
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        return self.refreshControl?.isRefreshing == true
    }

    var numberOfRenderedFeedItems: Int {
        return self.tableView.numberOfRows(inSection: self.feedItemsSectionIndex)
    }

    var feedItemsSectionIndex: Int {
        return 0
    }

    func simulateUserInitiatedFeedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }

    func feedImageView(at index: Int) -> UIView? {
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        return self.tableView?.dataSource?.tableView(self.tableView, cellForRowAt: index)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !self.locationContainer.isHidden
    }

    var locationText: String? {
        return self.locationLabel.text
    }

    var descriptionText: String? {
        return self.descriptionLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
