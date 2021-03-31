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
        let feedViewModel = FeedViewModel.init(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController.init(viewModel: feedViewModel)
        let feedVC = FeedViewController.init(refreshController: refreshController)
        feedViewModel.onFeedLoad = Self.adaptFeedToCellControllers(forwardingTo: feedVC, imageLoader: imageLoader)
        return feedVC
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
