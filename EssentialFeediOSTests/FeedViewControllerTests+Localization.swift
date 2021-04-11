//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import XCTest
import EssentialFeediOS

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle.init(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        XCTAssertNotEqual(key, value, file: file, line: line)
        return value
    }
}
