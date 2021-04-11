//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        // MARK: FeedLoader
        private(set) var completions: [(FeedLoader.Result) -> Void] = []

        var loadCallCount: Int  {
            return self.completions.count
        }

        init() { }

        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            self.completions.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            self.completions[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError.init(domain: "any-error", code: 0)
            self.completions[index](.failure(error))
        }

        // MARK: FeedImageDataLoader
        struct TaskSpy: FeedImageDataLoaderTask {
            let cancelAction: () -> Void
            func cancel() {
                self.cancelAction()
            }
        }

        var imageRequests: [(url: URL, completion: ((FeedImageDataLoader.Result) -> Void))] = []
        var loadedImageURLs: [URL] {
            return self.imageRequests.map { $0.url }
        }
        var canceledImageURLRequests: [URL] = []

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            self.imageRequests.append((url, completion))
            return TaskSpy.init { [weak self] in
                self?.canceledImageURLRequests.append(url)
            }
        }

        func completeImageDataLoading(with data: Data, at index: Int) {
            self.imageRequests[index].completion(.success(data))
        }

        func completeImageDataLoadingWithError(at index: Int) {
            let error = NSError.init(domain: "any-error", code: 0)
            self.imageRequests[index].completion(.failure(error))
        }
    }
}
