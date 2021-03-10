//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.loadAndReturn(modelName: "FeedStore", url: storeURL, in: bundle)
        self.context = self.container.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = self.context
        context.perform {
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
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
        let context = self.context
        context.perform {
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
}

private extension NSPersistentContainer {
    private enum LoadError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }

    class func loadAndReturn(modelName: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let momd = NSManagedObjectModel.with(modelName: modelName, in: bundle)
        else { throw LoadError.modelNotFound }

        let description = NSPersistentStoreDescription.init(url: url)
        let container = NSPersistentContainer.init(name: "FeedStore", managedObjectModel: momd)
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadError.failedToLoadPersistentStore($0) }

        return container
    }
}

private extension NSManagedObjectModel {
    class func with(modelName: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: modelName, withExtension: "momd")
            .flatMap { NSManagedObjectModel.init(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet

    var localFeed: [LocalFeedImage] {
        return self.feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }

    class func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>.init(entityName: Self.entity().name!)
        request.returnsObjectsAsFaults = false
        return try? context.fetch(request).first
    }

    class func firstInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try Self.find(in: context).map { context.delete($0) }
        return ManagedCache.init(context: context)
    }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache

    var local: LocalFeedImage {
        return LocalFeedImage(id: self.id, description: self.imageDescription, location: self.location, url: self.url)
    }

    class func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: feed.map {
            let managedImage = ManagedFeedImage.init(context: context)
            managedImage.id = $0.id
            managedImage.imageDescription = $0.description
            managedImage.location = $0.location
            managedImage.url = $0.url
            return managedImage
        })
    }
}
