//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-17.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = self.loadView()

    private let presenter: FeedPresenter

    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        self.presenter.loadFeed()
    }

    func display(isLoading: Bool) {
        if isLoading {
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
