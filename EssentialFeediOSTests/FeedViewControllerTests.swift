//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-03-13.
//

import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private(set) var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(self.load), for: .valueChanged)

        self.load()
    }

    @objc private func load() {
        self.loader?.load { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = self.makeSUT()

        XCTAssertEqual(loader.loadCallCount, .zero)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = self.makeSUT()

        sut.refreshControl?.allTargets.forEach { target in
            sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }

        XCTAssertEqual(loader.loadCallCount, 2)
    }

    // MARK: Private methods

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedViewController, FeedLoaderSpy) {
        let loader = FeedLoaderSpy.init()
        let sut = FeedViewController.init(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
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
