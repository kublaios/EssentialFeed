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
    private let feedView: FeedView
    private let loadingView: FeedLoadingView

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        self.loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoading(with feed: [FeedImage]) {
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
        self.feedView.display(FeedViewModel(feed: feed))
    }

    func didFinishLoading(with error: Error) {
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
