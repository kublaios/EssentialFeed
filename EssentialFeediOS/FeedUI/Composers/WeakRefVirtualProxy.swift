//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit

final class WeekRefVirtualProxy<T: AnyObject> {
    private weak var obj: T?

    init(_ obj: T) {
        self.obj = obj
    }
}

extension WeekRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        self.obj?.display(viewModel)
    }
}

extension WeekRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        self.obj?.display(model)
    }
}
