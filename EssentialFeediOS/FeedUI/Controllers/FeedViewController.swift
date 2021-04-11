//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, FeedLoadingView {
    var delegate: FeedViewControllerDelegate?

    var tableModel: [FeedImageCellController] = [] {
        didSet { self.tableView.reloadData() }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = FeedPresenter.title

        self.refresh()
    }

    @IBAction func refresh() {
        self.delegate?.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: Private methods

    private func cancelCellControllerLoading(forRowAt indexPath: IndexPath) {
        self.tableModel[indexPath.row].cancel()
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return self.tableModel[indexPath.row]
    }

    // MARK: UITableViewDataSource

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellController(forRowAt: indexPath).view(in: tableView)
    }

    // MARK: UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cancelCellControllerLoading(forRowAt: indexPath)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { [weak self] (indexPath) in
            self?.cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(self.cancelCellControllerLoading)
    }
}
