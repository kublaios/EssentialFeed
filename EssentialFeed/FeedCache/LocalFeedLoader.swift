//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?

    private let store: FeedStore
    private let timestampProvider: () -> Date

    public init(store: FeedStore, timestampProvider: @escaping () -> Date) {
        self.store = store
        self.timestampProvider = timestampProvider
    }

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }

    public func load() {
        self.store.retrieve()
    }

    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(feed.toLocalFeedImages(), timestamp: self.timestampProvider()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedImages() -> [LocalFeedImage] {
        return self.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}
