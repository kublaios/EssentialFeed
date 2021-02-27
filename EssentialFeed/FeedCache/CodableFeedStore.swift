//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-27.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return self.feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }

        var local: LocalFeedImage {
            return LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
        }
    }

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: self.storeURL)
        else { return completion(.empty) }

        do {
            let decoder = JSONDecoder.init()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.error(error))
        }
    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoder = JSONEncoder.init()
            let data = try encoder.encode(cache)
            try data.write(to: self.storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: self.storeURL.path)
        else { return completion(nil) }

        do {
            try FileManager.default.removeItem(at: self.storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
