//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.loadAndReturn(modelName: "FeedStore", url: storeURL, in: bundle)
        self.context = self.container.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.perform { (context) in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        self.perform { (context) in
            do {
                let managedCache = try ManagedCache.firstInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        self.perform { (context) in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.error(error))
            }
        }
    }

    private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
