//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UIViewController {
    private(set) var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader?.load { _ in }
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
    class FeedLoaderSpy: FeedLoader {
        private(set) var loadCallCount = 0

        init() { }

        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            self.loadCallCount += 1
        }
    }
}
