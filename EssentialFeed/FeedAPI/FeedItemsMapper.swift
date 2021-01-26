//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-26.
//

import Foundation

public final class FeedItemsMapper {

    private struct Root: Decodable {
        let items: [Item]
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
        guard response.statusCode == Self.OK_200
        else {
            return .failure(.invalidData)
        }

        do {
            let root = try JSONDecoder.init().decode(Root.self, from: data)
            let items = root.items.map({ $0.feedItem })
            return .success(items)
        }
        catch {
            return .failure(.invalidData)
        }
    }

}
