//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import Foundation

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
