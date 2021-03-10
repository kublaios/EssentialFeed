//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-03-10.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyResultOnEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatRetrieveDeliversEmptyResultOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValues_onNonEmptyCache() {

    }

    func test_retrieve_afterInsertingToEmptyCache_hasNoSideEffects() {

    }

    func test_insert_deliversNoError_onEmptyCache() {

    }

    func test_insert_deliversNoError_onNonEmptyCache() {

    }

    func test_insert_uponNonEmptyCache_overridesCache_withoutSideEffects() {

    }

    func test_delete_emtpyCache_completesWithoutError() {

    }

    func test_delete_emtpyCache_hasNoSideEffects() {

    }

    func test_delete_nonEmptyCache_deletesExistingCache() {

    }

    func test_delete_nonEmptyCache_deletesExistingCache_withoutSideEffects() {

    }

    func test_storeSideEffects_runSerially() {

    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle.init(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore.init(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
