//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-01.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    private struct UnexpectedValuesRepresentation: Error { }

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        self.session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                } else if let d = data, let r = response as? HTTPURLResponse {
                    return (d, r)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
