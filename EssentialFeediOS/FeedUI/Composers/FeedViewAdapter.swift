//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(viewController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = viewController
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        self.controller?.tableModel = viewModel.feed.map { (model) in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeekRefVirtualProxy<FeedImageCellController>, UIImage>.init(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController.init(delegate: adapter)

            adapter.presenter = FeedImagePresenter.init(view: WeekRefVirtualProxy.init(view),
                                                        imageTransformer: UIImage.init)

            return view
        }
    }
}
