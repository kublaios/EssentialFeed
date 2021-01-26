//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-26.
//

import Foundation

public final class FeedItemsMapper {

    private struct Root: Decodable {
        private let items: [Item]
        public var feedItems: [FeedItem] {
            return self.items.map({ $0.feedItem })
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL

        var feedItem: FeedItem {
            return FeedItem(id: self.id,
                            description: self.description,
                            location: self.location,
                            imageURL: self.imageURL)
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case description
            case location
            case imageURL = "image"
        }
    }

    private static let OK_200 = 200

    public static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == Self.OK_200,
              let root = try? JSONDecoder.init().decode(Root.self, from: data)
        else {
            return .failure(.invalidData)
        }

        return .success(root.feedItems)
    }

}
