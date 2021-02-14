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
        self.store.insertCache(items, timestamp: self.timestampProvider()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}
