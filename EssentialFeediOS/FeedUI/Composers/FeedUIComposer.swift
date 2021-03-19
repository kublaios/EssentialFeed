//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-19.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init() { }

    public class func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController.init(feedLoader: feedLoader)
        let feedVC = FeedViewController.init(refreshController: refreshController)
        refreshController.onRefresh = Self.adaptFeedToCellControllers(forwardingTo: feedVC, imageLoader: imageLoader)
        return feedVC
    }

    private class func adaptFeedToCellControllers(forwardingTo viewController: FeedViewController,
                                                  imageLoader: FeedImageDataLoader)
    -> ([FeedImage]) -> Void
    {
        return { [weak viewController] (feed) in
            viewController?.tableModel = feed.map {
                FeedImageCellController.init(model: $0, imageLoader: imageLoader)
            }
        }
    }
}
