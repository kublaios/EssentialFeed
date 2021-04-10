//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-19.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        self.delegate.didRequestImage()
        return self.cell!
    }

    func preload() {
        self.delegate.didRequestImage()
    }

    func cancel() {
        self.releaseCellForReuse()
        self.delegate.didCancelImageRequest()
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        self.cell?.locationContainer.isHidden = !viewModel.hasLocation
        self.cell?.locationLabel.text = viewModel.location
        self.cell?.descriptionLabel.text = viewModel.description
        self.cell?.feedImageView.image = viewModel.image
        self.cell?.feedImageContainer.isShimmering = viewModel.isLoading
        self.cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        self.cell?.retryButtonAction = self.delegate.didRequestImage
    }

    private func releaseCellForReuse() {
        self.cell = nil
    }
}
