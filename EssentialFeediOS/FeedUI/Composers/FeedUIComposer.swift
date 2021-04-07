//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-19.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() { }

    public class func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter.init()
        let presentationAdapter = FeedLoaderPresentationAdapter.init(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController.init(delegate: presentationAdapter)
        let feedController = FeedViewController.init(refreshController: refreshController)
        presenter.feedView = FeedViewAdapter.init(viewController: feedController, imageLoader: imageLoader)
        presenter.loadingView = WeekRefVirtualProxy.init(refreshController)
        return feedController
    }

    private class func adaptFeedToCellControllers(forwardingTo viewController: FeedViewController,
                                                  imageLoader: FeedImageDataLoader)
    -> ([FeedImage]) -> Void
    {
        return { [weak viewController] (feed) in
            viewController?.tableModel = feed.map {
                let imageViewModel = FeedImageViewModel<UIImage>.init(model: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
                return FeedImageCellController.init(viewModel: imageViewModel)
            }
        }
    }
}

private final class WeekRefVirtualProxy<T: AnyObject> {
    private weak var obj: T?

    init(_ obj: T) {
        self.obj = obj
    }
}

extension WeekRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        self.obj?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(viewController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = viewController
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        self.controller?.tableModel = viewModel.feed.map {
            let imageViewModel = FeedImageViewModel<UIImage>.init(model: $0, imageLoader: self.imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController.init(viewModel: imageViewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let feedLoader: FeedLoader
    let presenter: FeedPresenter

    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func didRequestFeedRefresh() {
        self.presenter.didStartLoadingFeed()
        self.feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoading(with: feed)
            case let .failure(error):
                self?.presenter.didFinishLoading(with: error)
            }
        }
    }

}
