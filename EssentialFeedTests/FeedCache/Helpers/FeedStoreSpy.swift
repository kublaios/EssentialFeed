//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-22.
//

import EssentialFeed

class FeedStoreSpy: FeedStore {

    enum RequestedCommand: Equatable {
        case deleteCachedFeed
        case insertCache([LocalFeedImage], Date)
        case retrieve
    }

    var deletionCompletions: [DeletionCompletion] = []
    var insertionCompletions: [InsertionCompletion] = []
    var cacheInsertions: [(feed: [LocalFeedImage], timestamp: Date)] = []
    private(set) var requestedCommands: [RequestedCommand] = []

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.deletionCompletions.append(completion)
        self.requestedCommands.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        self.deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        self.deletionCompletions[index](nil)
    }

    func insertCache(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        self.insertionCompletions.append(completion)
        self.cacheInsertions.append((feed, timestamp))
        self.requestedCommands.append(.insertCache(feed, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        self.insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        self.insertionCompletions[index](nil)
    }

    func retrieve() {
        self.requestedCommands.append(.retrieve)
    }
}
