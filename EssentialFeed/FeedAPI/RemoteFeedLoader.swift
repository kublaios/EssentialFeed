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
                completion(Self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items.toFeedImages())
        }
        catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toFeedImages() -> [FeedImage] {
        return self.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) })
    }
}
