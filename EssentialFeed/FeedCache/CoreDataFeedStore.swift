//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    public init() { }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
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
