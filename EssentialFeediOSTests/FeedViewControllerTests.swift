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

        self.refreshControl?.beginRefreshing()
        self.load()
    }

    @objc private func load() {
        self.loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
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

        sut.refreshControl?.simulatePullToRefresh()

        XCTAssertEqual(loader.loadCallCount, 2)
    }

    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = self.makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.refreshControl?.isRefreshing == true)
    }

    func test_viewDidLoad_hidesLoadingIndicator_whenLoadingIsCompleted() {
        let (sut, loader) = self.makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading()

        XCTAssertTrue(sut.refreshControl?.isRefreshing == false)
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

private extension FeedViewControllerTests {
    class FeedLoaderSpy: FeedLoader {
        private(set) var completions: [(FeedLoader.Result) -> Void] = []

        var loadCallCount: Int  {
            return self.completions.count
        }

        init() { }

        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            self.completions.append(completion)
        }

        func completeLoading() {
            self.completions[0](.success([]))
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
