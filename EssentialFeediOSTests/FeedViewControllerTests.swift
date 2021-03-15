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
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator after the feed is loaded successfully")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when the feed is being loaded")

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator after the feed is failed to load")
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

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URLs until feed image views become visible")

        sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first feed image view becomes visible")

        sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second feed image view becomes visible")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.canceledImageURLRequests, [], "Expected no cancelled image URLs requests until feed image view is not visible")

        sut.simulateImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLRequests, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLRequests, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }

    func test_feedImageView_showsShimmeringAnimation_whenFeedItemIsLoadingImage() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0) as? FeedImageCell
        let view1 = sut.feedImageView(at: 1) as? FeedImageCell
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected first feed image view to show loading image indicator!")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second feed image view to show loading image indicator!")

        loader.completeImageDataLoading(with: "image-data".data(using: .utf8)!, at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected first feed image view to hide loading image indicator after the image is loaded with data!")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second feed image view to show loading image indicator!")

        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected first feed image view to hide loading image indicator after the image is loaded with data!")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected second feed image view to hide loading image indicator after the image failed to load!")
    }

    func test_feedImageView_rendersLoadedImages() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.feedImageView(at: 0) as? FeedImageCell
        let view1 = sut.feedImageView(at: 1) as? FeedImageCell
        XCTAssertEqual(view0?.renderedImageData, .none, "Expected first feed image view to show no image when the image is being loaded!")
        XCTAssertEqual(view1?.renderedImageData, .none, "Expected second feed image view to show no image when the image is being loaded!")

        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageDataLoading(with: image0Data, at: 0)
        XCTAssertEqual(view0?.renderedImageData, image0Data, "Expected first feed image view to render loaded image!")
        XCTAssertEqual(view1?.renderedImageData, .none, "Expected second feed image view to show no image when the image is being loaded!")

        let image1Data = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageDataLoading(with: image1Data, at: 1)
        XCTAssertEqual(view0?.renderedImageData, image0Data, "Expected first feed image view to render loaded image!")
        XCTAssertEqual(view1?.renderedImageData, image1Data, "Expected second feed image view to render loaded image!")
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, FeedLoaderSpy) {
        let loader = FeedLoaderSpy.init()
        let sut = FeedViewController.init(feedLoader: loader, imageLoader: loader)
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
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        // MARK: FeedLoader
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

        // MARK: FeedImageDataLoader
        struct TaskSpy: FeedImageDataLoaderTask {
            let cancelAction: () -> Void
            func cancel() {
                self.cancelAction()
            }
        }

        var imageRequests: [(url: URL, completion: ((FeedImageDataLoader.Result) -> Void))] = []
        var loadedImageURLs: [URL] {
            return self.imageRequests.map { $0.url }
        }
        var canceledImageURLRequests: [URL] = []

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            self.imageRequests.append((url, completion))
            return TaskSpy.init { [weak self] in
                self?.canceledImageURLRequests.append(url)
            }
        }

        func completeImageDataLoading(with data: Data, at index: Int) {
            self.imageRequests[index].completion(.success(data))
        }

        func completeImageDataLoadingWithError(at index: Int) {
            let error = NSError.init(domain: "any-error", code: 0)
            self.imageRequests[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        return self.refreshControl?.isRefreshing == true
    }

    var numberOfRenderedFeedItems: Int {
        return self.tableView(self.tableView, numberOfRowsInSection: self.feedItemsSectionIndex)
    }

    var feedItemsSectionIndex: Int {
        return 0
    }

    func simulateUserInitiatedFeedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }

    func simulateImageViewVisible(at index: Int) {
        let _ = self.feedImageView(at: index)
    }

    func simulateImageViewNotVisible(at index: Int) {
        let cell = self.feedImageView(at: index) as! FeedImageCell
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        self.tableView(self.tableView, didEndDisplaying: cell, forRowAt: index)
    }

    func feedImageView(at index: Int) -> UIView? {
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        return self.tableView(self.tableView, cellForRowAt: index)
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

    var isShowingImageLoadingIndicator: Bool {
        return self.feedImageContainer.isShimmering
    }

    var renderedImageData: Data? {
        self.feedImageView.image?.pngData()
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
