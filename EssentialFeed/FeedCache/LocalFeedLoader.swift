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

    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        self.store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(items.toLocalFeedItems(), timestamp: self.timestampProvider()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension Array where Element == FeedItem {
    func toLocalFeedItems() -> [LocalFeedItem] {
        return self.map({ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) })
    }
}
