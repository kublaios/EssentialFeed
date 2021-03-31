//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-17.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        return self.binded(UIRefreshControl.init())
    }()

    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        self.viewModel.loadFeed()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        self.viewModel.onChange = { [weak self] (viewModel) in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return view
    }
}
