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
        let presentationAdapter = FeedLoaderPresentationAdapter.init(feedLoader: MainQueueDispatchDecorator.init(decoratee: feedLoader))
        let feedController = Self.makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        let feedViewAdapter = FeedViewAdapter.init(viewController: feedController, imageLoader: MainQueueDispatchDecorator.init(decoratee: imageLoader))
        presentationAdapter.presenter = FeedPresenter.init(feedView: feedViewAdapter, loadingView: WeekRefVirtualProxy.init(feedController))
        return feedController
    }

    private class func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle.init(for: FeedViewController.self)
        let storyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
