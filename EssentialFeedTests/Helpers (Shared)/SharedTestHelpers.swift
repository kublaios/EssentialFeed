//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-24.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError.init(domain: "any-error", code: 0)
}
