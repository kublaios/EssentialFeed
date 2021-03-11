//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
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
