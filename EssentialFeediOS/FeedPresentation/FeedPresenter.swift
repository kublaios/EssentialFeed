//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-07.
//

import EssentialFeed

protocol FeedLoadingView: class {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private enum State {
        case pending, loading, loaded([FeedImage]), failed
    }
    private let feedLoader: FeedLoader

    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        self.loadingView?.display(isLoading: true)
        self.feedLoader.load { [weak self] result in
            self?.loadingView?.display(isLoading: false)
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
        }
    }
}
