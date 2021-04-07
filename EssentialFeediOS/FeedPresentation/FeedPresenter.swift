//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-07.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private enum State {
        case pending, loading, loaded([FeedImage]), failed
    }
    private let feedLoader: FeedLoader

    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
        self.feedLoader.load { [weak self] result in
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
        }
    }
}
