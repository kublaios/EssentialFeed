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
            if let e = error {
                completion(.failure(e))
            } else if let d = data, let r = response as? HTTPURLResponse {
                completion(.success((d, r)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
