//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-19.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell.init()
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true

        let loadImage: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] (result) in
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

    func preload() {
        self.task = self.imageLoader.loadImageData(from: self.model.url) { _ in }
    }

    func cancel() {
        self.task?.cancel()
    }

}
