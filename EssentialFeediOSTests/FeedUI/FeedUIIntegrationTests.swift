//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = self.makeSUT()

        sut.loadViewIfNeeded()

        let localizedTitle = self.localized("FEED_VIEW_TITLE")
        XCTAssertEqual(sut.title, localizedTitle)
    }

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

        let view0 = sut.simulateImageViewVisible(at: 0) as? FeedImageCell
        let view1 = sut.simulateImageViewVisible(at: 1) as? FeedImageCell
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

        let view0 = sut.simulateImageViewVisible(at: 0) as? FeedImageCell
        let view1 = sut.simulateImageViewVisible(at: 1) as? FeedImageCell
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

    func test_feedImageView_showsRetryButtonOnImageLoadingError() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateImageViewVisible(at: 0) as? FeedImageCell
        let view1 = sut.simulateImageViewVisible(at: 1) as? FeedImageCell
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected first feed image view to hide retry button when first image is being loaded!")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected second feed image view to hide retry button when second image is being loaded!")

        loader.completeImageDataLoadingWithError(at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, true, "Expected first feed image view to show retry button when first image is failed to load!")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected second feed image view to hide retry button when second image is being loaded!")

        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, true, "Expected first feed image view to show retry button when first image is failed to load!")
        XCTAssertEqual(view1?.isShowingRetryButton, true, "Expected second feed image view to show retry button when second image is failed to load!")
    }

    func test_feedImageView_showsRetryButtonOnInvalidImageData() {
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [self.makeImage()], at: 0)

        let view0 = sut.simulateImageViewVisible(at: 0) as? FeedImageCell
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected first feed image view to hide retry button when first image is being loaded!")

        loader.completeImageDataLoading(with: "invalid-image-data".data(using: .utf8)!, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, true, "Expected first feed image view to show retry button when first image is failed to load!")
    }

    func test_feedImageView_retriesLoadingImage() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        let view0 = sut.simulateImageViewVisible(at: 0) as? FeedImageCell
        let view1 = sut.simulateImageViewVisible(at: 1) as? FeedImageCell
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected first and second image URLs are being loaded!")

        loader.completeImageDataLoadingWithError(at: 0)
        loader.completeImageDataLoadingWithError(at: 1)
        view0?.simulateUserInitiatedRetryAction()

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected first image URL is being loaded again!")

        view1?.simulateUserInitiatedRetryAction()

        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected second image URL is being loaded again!")
    }

    func test_feedImageView_preloadImageURLWhenNearVisible() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        sut.simulateImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL is being loaded when it is near visible!")

        sut.simulateImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL is being loaded when it is near visible!")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotNearVisibleAnymore() {
        let image0 = self.makeImage(url: URL(string: "https://image-0-url.com")!)
        let image1 = self.makeImage(url: URL(string: "https://image-1-url.com")!)
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.canceledImageURLRequests, [], "Expected no cancelled image URLs requests until feed image view is not near visible")

        sut.simulateImageViewNearVisible(at: 0)
        sut.simulateImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLRequests, [image0.url], "Expected one cancelled image URL request once first image is not near visible anymore")

        sut.simulateImageViewNearVisible(at: 1)
        sut.simulateImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLRequests, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not near visible anymore")
    }

    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let index = 0
        let (sut, loader) = self.makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [self.makeImage()], at: index)

        let view = sut.simulateImageViewNotVisible(at: index)
        loader.completeImageDataLoading(with: self.anyImageData(), at: index)

        XCTAssertNil(view.renderedImageData, "Expected no rendered image after the view is not visible anymore!")
    }

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = self.makeSUT()
        sut.loadViewIfNeeded()

        let exp = self.expectation(description: "Waiting for Feedloader to complete on the bg queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: .zero)
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)
    }

    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let index = Int.zero
        let (sut, loader) = self.makeSUT()
        sut.loadViewIfNeeded()

        loader.completeFeedLoading(with: [self.makeImage()], at: index)
        _ = sut.simulateImageViewVisible(at: index)

        let exp = self.expectation(description: "Waiting for Feedloader to complete on the bg queue")
        DispatchQueue.global().async {
            loader.completeImageDataLoading(with: self.anyImageData(), at: index)
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 1.0)
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, FeedLoaderSpy) {
        let loader = FeedLoaderSpy.init()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://any-url.com")!) -> FeedImage {
        return FeedImage.init(id: UUID(), description: description, location: location, url: url)
    }

    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
}
