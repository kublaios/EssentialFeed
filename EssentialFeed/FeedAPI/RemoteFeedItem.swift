//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-16.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
