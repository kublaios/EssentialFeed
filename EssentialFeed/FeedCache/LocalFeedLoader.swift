//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    private let store: FeedStore
    private let timestampProvider: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    private var maxCacheAgeInDays: Int {
        return 7
    }

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

    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case let .error(error):
                self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
            case let .found(feed, timestamp) where self.validateTimestamp(timestamp):
                completion(.success(feed.toFeedImages()))
            case .found:
                self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }

    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(feed.toLocalFeedImages(), timestamp: self.timestampProvider()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }

    private func validateTimestamp(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = self.calendar.date(byAdding: .day, value: self.maxCacheAgeInDays, to: timestamp)
        else { return false }

        let currentDate = self.timestampProvider()
        return currentDate < maxCacheAge
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
