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
        let presenter = FeedPresenter.init(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController.init(presenter: presenter)
        let feedController = FeedViewController.init(refreshController: refreshController)
        presenter.feedView = FeedViewAdapter.init(viewController: feedController, imageLoader: imageLoader)
        presenter.loadingView = refreshController
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

private final class FeedViewAdapter: FeedView{
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(viewController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = viewController
        self.imageLoader = imageLoader
    }

    func display(feed: [FeedImage]) {
        self.controller?.tableModel = feed.map {
            let imageViewModel = FeedImageViewModel<UIImage>.init(model: $0, imageLoader: self.imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController.init(viewModel: imageViewModel)
        }
    }
}
