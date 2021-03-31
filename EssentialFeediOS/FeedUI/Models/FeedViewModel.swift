//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-31.
//

import EssentialFeed

final class FeedViewModel {
    private enum State {
        case pending, loading, loaded([FeedImage]), failed
    }
    private let feedLoader: FeedLoader
    private(set) var isLoading: Bool = false {
        didSet {
            self.onChange?(self)
        }
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        self.isLoading = true
        self.feedLoader.load { [weak self] result in
            self?.isLoading = false
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
        }
    }
}
