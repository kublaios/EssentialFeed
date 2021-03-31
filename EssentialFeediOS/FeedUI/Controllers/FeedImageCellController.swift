//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-19.
//

import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel

    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = self.binded(FeedImageCell.init())
        self.viewModel.loadImageData()
        return cell
    }

    func preload() {
        self.viewModel.loadImageData()
    }

    func cancel() {
        self.viewModel.cancelImageDataLoad()
    }

    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !self.viewModel.hasLocation
        cell.locationLabel.text = self.viewModel.location
        cell.descriptionLabel.text = self.viewModel.description
        cell.retryButtonAction = self.viewModel.loadImageData

        self.viewModel.onImageLoad = { [weak cell] (image) in
            cell?.feedImageView.image = image
        }

        self.viewModel.onImageLoadingStateChange = { [weak cell] (isLoading) in
            cell?.feedImageContainer.isShimmering = isLoading
        }

        self.viewModel.onShouldRetryImageLoadStateChange = { [weak cell] (shouldRetry) in
            cell?.retryButton.isHidden = !shouldRetry
        }

        return cell
    }
}
