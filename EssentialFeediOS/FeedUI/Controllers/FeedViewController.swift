//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import UIKit

public final class FeedViewController: UITableViewController {
    private(set) var refreshController: FeedRefreshViewController?

    var tableModel: [FeedImageCellController] = [] {
        didSet { self.tableView.reloadData() }
    }

    convenience init?(coder: NSCoder, refreshController: FeedRefreshViewController) {
        self.init(coder: coder)
        self.refreshController = refreshController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.prefetchDataSource = self
        self.refreshControl = self.refreshController?.view
        self.refreshController?.refresh()
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
        return self.cellController(forRowAt: indexPath).view()
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
