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

    public init(bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.loadAndReturn(modelName: "FeedStore", in: bundle)
        self.context = self.container.newBackgroundContext()
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private extension NSPersistentContainer {
    private enum LoadError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }

    class func loadAndReturn(modelName: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let momd = NSManagedObjectModel.with(modelName: modelName, in: bundle)
        else { throw LoadError.modelNotFound }

        let container = NSPersistentContainer.init(name: "FeedStore", managedObjectModel: momd)
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

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var cache: ManagedCache
}
