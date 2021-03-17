//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-17.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl.init()
        view.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return view
    }()

    private let feedLoader: FeedLoader
    var onRefresh: (([FeedImage]) -> Void)?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func refresh() {
        self.view.beginRefreshing()
        self.feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
