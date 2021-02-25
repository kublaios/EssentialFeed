//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import Foundation

private final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        return 7
    }

    private init() { }

    static func validateTimestamp(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Self.calendar.date(byAdding: .day, value: Self.maxCacheAgeInDays, to: timestamp)
        else { return false }

        return date < maxCacheAge
    }
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let timestampProvider: () -> Date

    public init(store: FeedStore, timestampProvider: @escaping () -> Date) {
        self.store = store
        self.timestampProvider = timestampProvider
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

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

    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCache(feed.toLocalFeedImages(), timestamp: self.timestampProvider()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        self.store.retrieve { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case let .error(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where FeedCachePolicy.validateTimestamp(timestamp, against: self.timestampProvider()):
                completion(.success(feed.toFeedImages()))
            case .found, .empty:
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
            case .error:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !FeedCachePolicy.validateTimestamp(timestamp, against: self.timestampProvider()):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found:
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
