//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-17.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = self.loadView()

    private let delegate: FeedRefreshViewControllerDelegate

    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }

    @objc func refresh() {
        self.delegate.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            self.view.beginRefreshing()
        } else {
            self.view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl.init()
        view.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return view
    }
}
