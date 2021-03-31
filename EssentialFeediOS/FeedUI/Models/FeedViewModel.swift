//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-31.
//

import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private enum State {
        case pending, loading, loaded([FeedImage]), failed
    }
    private let feedLoader: FeedLoader

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        self.onLoadingStateChange?(true)
        self.feedLoader.load { [weak self] result in
            self?.onLoadingStateChange?(false)
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
        }
    }
}
