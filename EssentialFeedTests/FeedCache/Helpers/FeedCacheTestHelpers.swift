//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-24.
//

import Foundation
import EssentialFeed

func uniqueImagesFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let localImages = models.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    return (models, localImages)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "a-desc", location: "a-loc", url: anyURL())
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -7)
    }

    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
