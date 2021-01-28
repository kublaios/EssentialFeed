//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-24.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity, invalidData
    }

    public typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        self.client.get(from: self.url) { [weak self] (result) in
            guard self != nil else { return }

            switch result {
            case let .success(data, response):
                let result = FeedItemsMapper.map(data, response)
                completion(result)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
