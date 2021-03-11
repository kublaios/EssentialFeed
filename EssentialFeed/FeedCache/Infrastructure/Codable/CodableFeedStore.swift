//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-27.
//

import Foundation

public final class CodableFeedStore: FeedStore {
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
    private let queue = DispatchQueue.init(label: "\(type(of: CodableFeedStore.self))Queue", qos: .userInitiated, attributes: .concurrent)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        self.queue.async {
            guard let data = try? Data(contentsOf: storeURL)
            else { return completion(.success(.empty)) }

            do {
                let decoder = JSONDecoder.init()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.found(feed: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        self.queue.async(flags: .barrier) {
            do {
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoder = JSONEncoder.init()
                let data = try encoder.encode(cache)
                try data.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        self.queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path)
            else { return completion(nil) }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
