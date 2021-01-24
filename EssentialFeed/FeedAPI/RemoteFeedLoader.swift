//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        self.client.get(from: self.url) { (error) in
            completion(.connectivity)
        }
    }
}
