//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest
import UIKit

class FeedViewController: UIViewController {
    private(set) var loader: FeedViewControllerTests.FeedLoaderSpy?

    convenience init(loader: FeedViewControllerTests.FeedLoaderSpy) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader?.load()
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = FeedLoaderSpy.init()
        let _ = FeedViewController.init(loader: loader)

        XCTAssertEqual(loader.loadCallCount, .zero)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = FeedLoaderSpy.init()
        let sut = FeedViewController.init(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }
}

extension FeedViewControllerTests {
    class FeedLoaderSpy {
        private(set) var loadCallCount = 0

        init() { }

        func load() {
            self.loadCallCount += 1
        }
    }
}
