//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private(set) var loader: FeedLoader?

    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(self.load), for: .valueChanged)

        self.load()
    }

    @objc private func load() {
        self.refreshControl?.beginRefreshing()
        self.loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
