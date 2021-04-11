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
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        let feedViewAdapter = FeedViewAdapter.init(viewController: feedController, imageLoader: MainQueueDispatchDecorator.init(decoratee: imageLoader))
        presentationAdapter.presenter = FeedPresenter.init(feedView: feedViewAdapter, loadingView: WeekRefVirtualProxy.init(feedController))
        return feedController
    }
}

private extension FeedViewController {
    class func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle.init(for: FeedViewController.self)
        let storyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
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
        self.controller?.tableModel = viewModel.feed.map { (model) in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeekRefVirtualProxy<FeedImageCellController>, UIImage>.init(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController.init(delegate: adapter)

            adapter.presenter = FeedImagePresenter.init(view: WeekRefVirtualProxy.init(view),
                                                        imageTransformer: UIImage.init)

            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        self.presenter?.didStartLoadingFeed()
        self.feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoading(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}
