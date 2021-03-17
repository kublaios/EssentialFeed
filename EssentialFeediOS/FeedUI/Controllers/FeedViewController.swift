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
    private var tasks: [IndexPath: FeedImageDataLoaderTask] = [:]

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
        let imageModel = self.tableModel[indexPath.row]
        let cell = FeedImageCell.init()
        cell.locationContainer.isHidden = imageModel.location == nil
        cell.locationLabel.text = imageModel.location
        cell.descriptionLabel.text = imageModel.description
        cell.feedImageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true

        let loadImage: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: imageModel.url) { [weak cell] (result) in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.retryButtonAction = loadImage
        loadImage()

        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cancelTask(forRowAt: indexPath)
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        self.tasks[indexPath]?.cancel()
        self.tasks[indexPath] = nil
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { [weak self] (indexPath) in
            guard let self = self else { return }
            let imageModel = self.tableModel[indexPath.row]
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: imageModel.url) { _ in }
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(self.cancelTask)
    }
}
