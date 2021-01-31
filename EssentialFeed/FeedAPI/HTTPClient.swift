//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-01-26.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
