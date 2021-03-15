//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

public final class FeedViewController: UITableViewController {
    private(set) var feedLoader: FeedLoader?
    private(set) var imageLoader: FeedImageDataLoader?

    private var tableModel: [FeedImage] = []

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(self.load), for: .valueChanged)

        self.load()
    }

    @objc private func load() {
        self.refreshControl?.beginRefreshing()
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
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
        self.imageLoader?.loadImageData(from: imageModel.url)
        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageModel = self.tableModel[indexPath.row]
        self.imageLoader?.cancelImageDataLoad(from: imageModel.url)
    }
}
