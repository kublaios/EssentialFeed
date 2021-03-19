//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private(set) var refreshController: FeedRefreshViewController?
    private(set) var imageLoader: FeedImageDataLoader?

    private var tableModel: [FeedImage] = [] {
        didSet { self.tableView.reloadData() }
    }
    private var cellControllers: [IndexPath: FeedImageCellController] = [:]

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController.init(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.prefetchDataSource = self

        self.refreshControl = self.refreshController?.view
        self.refreshController?.onRefresh = { [weak self] (feed) in
            self?.tableModel = feed
        }

        self.refreshController?.refresh()
    }


    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellController(at: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.removeCellController(at: indexPath)
    }

    private func removeCellController(at indexPath: IndexPath) {
        self.cellControllers[indexPath] = nil
    }

    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        let imageModel = self.tableModel[indexPath.row]
        let cellController = FeedImageCellController.init(model: imageModel, imageLoader: self.imageLoader!)
        self.cellControllers[indexPath] = cellController
        return cellController
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { [weak self] (indexPath) in
            self?.cellController(at: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(self.removeCellController)
    }
}
