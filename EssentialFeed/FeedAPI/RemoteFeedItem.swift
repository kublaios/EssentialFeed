//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-16.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
