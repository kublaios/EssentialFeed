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
    @IBOutlet private(set) var view: UIRefreshControl?

    var delegate: FeedRefreshViewControllerDelegate?

    @IBAction func refresh() {
        self.delegate?.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            self.view?.beginRefreshing()
        } else {
            self.view?.endRefreshing()
        }
    }
}
