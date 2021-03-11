//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping ((Result) -> Void))
}
