//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult) -> Void))
}
