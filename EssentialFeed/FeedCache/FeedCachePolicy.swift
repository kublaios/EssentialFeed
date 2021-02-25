//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Kubilay Erdogan on 2021-02-25.
//

import Foundation

internal final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        return 7
    }

    private init() { }

    internal static func validateTimestamp(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Self.calendar.date(byAdding: .day, value: Self.maxCacheAgeInDays, to: timestamp)
        else { return false }

        return date < maxCacheAge
    }
}
