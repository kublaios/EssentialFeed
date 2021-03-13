//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.FeedLoaderSpy) { }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = FeedLoaderSpy.init()
        let _ = FeedViewController.init(loader: loader)

        XCTAssertEqual(loader.loadCallCount, .zero)
    }
}

extension FeedViewControllerTests {
    class FeedLoaderSpy {
        private(set) var loadCallCount = 0

        init() { }
    }
}
