//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult) -> Void))
}
