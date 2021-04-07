//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-07.
//

import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(description: model.description,
                                                  location: model.location,
                                                  image: nil,
                                                  isLoading: true,
                                                  shouldRetry: false)
        self.view.display(viewModel)
    }

    private struct InvalidImageDataError: Error { }

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = self.imageTransformer(data)
        else {
            return self.didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        let viewModel = FeedImageViewModel(description: model.description,
                                                   location: model.location,
                                                   image: image,
                                                   isLoading: false,
                                                   shouldRetry: false)
        self.view.display(viewModel)
    }

    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(description: model.description,
                                                  location: model.location,
                                                  image: nil,
                                                  isLoading: false,
                                                  shouldRetry: true)
        self.view.display(viewModel)
    }
}
