//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        return self.refreshControl?.isRefreshing == true
    }

    var numberOfRenderedFeedItems: Int {
        return self.tableView(self.tableView, numberOfRowsInSection: self.feedItemsSectionIndex)
    }

    var feedItemsSectionIndex: Int {
        return 0
    }

    func simulateUserInitiatedFeedReload() {
        self.refreshControl?.simulatePullToRefresh()
    }

    @discardableResult
    func simulateImageViewVisible(at index: Int) -> UIView? {
        return self.feedImageView(at: index)
    }

    @discardableResult
    func simulateImageViewNotVisible(at index: Int) -> FeedImageCell {
        let cell = self.feedImageView(at: index) as! FeedImageCell
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        self.tableView(self.tableView, didEndDisplaying: cell, forRowAt: index)
        return cell
    }

    func simulateImageViewNearVisible(at index: Int) {
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        self.tableView.prefetchDataSource?.tableView(self.tableView, prefetchRowsAt: [index])
    }

    func simulateImageViewNotNearVisible(at index: Int) {
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        self.tableView.prefetchDataSource?.tableView?(self.tableView, cancelPrefetchingForRowsAt: [index])
    }

    func feedImageView(at index: Int) -> UIView? {
        let index = IndexPath(row: index, section: self.feedItemsSectionIndex)
        return self.tableView(self.tableView, cellForRowAt: index)
    }
}
