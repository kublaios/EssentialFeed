//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-31.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void

    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var hasLocation: Bool {
        return self.model.location != nil
    }
    var location: String? {
        return self.model.location
    }
    var description: String? {
        return self.model.description
    }
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func loadImageData() {
        self.onImageLoadingStateChange?(true)
        self.onShouldRetryImageLoadStateChange?(false)

        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] (result) in
            self?.handle(result)
        }
    }

    func cancelImageDataLoad() {
        self.task?.cancel()
        self.task = nil
        self.onImageLoadingStateChange?(false)
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            self.onImageLoad?(image)
        } else {
            self.onShouldRetryImageLoadStateChange?(true)
        }
        self.onImageLoadingStateChange?(false)
    }
}
