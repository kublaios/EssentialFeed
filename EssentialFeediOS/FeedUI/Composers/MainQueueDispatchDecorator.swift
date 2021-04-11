//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
    let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread
        else { return DispatchQueue.main.async(execute: completion) }

        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        self.decoratee.load { [weak self] (result) in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        self.decoratee.loadImageData(from: url) { [weak self] (result) in
            self?.dispatch { completion(result) }
        }
    }
}
