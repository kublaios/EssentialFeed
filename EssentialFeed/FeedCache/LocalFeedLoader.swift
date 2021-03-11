//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let timestampProvider: () -> Date

    public init(store: FeedStore, timestampProvider: @escaping () -> Date) {
        self.store = store
        self.timestampProvider = timestampProvider
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.deleteCachedFeed { [weak self] (deletionResult) in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(feed, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(feed.toLocalFeedImages(), timestamp: self.timestampProvider()) { [weak self] (insertionResult) in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validateTimestamp(cache.timestamp, against: self.timestampProvider()):
                completion(.success(cache.feed.toFeedImages()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        self.store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validateTimestamp(cache.timestamp, against: self.timestampProvider()):
                self.store.deleteCachedFeed { _ in }
            case .success:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedImages() -> [LocalFeedImage] {
        return self.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}

private extension Array where Element == LocalFeedImage {
    func toFeedImages() -> [FeedImage] {
        return self.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}
