//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-14.
//

import Foundation

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
