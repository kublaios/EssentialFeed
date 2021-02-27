//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-26.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

    override func setUp() {
        super.setUp()

        self.setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        self.removeStoreSideEffects()
    }

    func test_retrieve_deliversEmptyResultOnEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatRetrieveDeliversEmptyResultOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValues_onNonEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_afterInsertingToEmptyCache_hasNoSideEffects() {
        let sut = self.makeSUT()

        self.assertThatRetrieveHasNoSideEffectsAfterInsertingToEmptyCache(on: sut)
    }

    func test_retrieve_deliversError_onRetrievalFailure() {
        let storeURL = self.testSpecificStoreURL()
        let sut = self.makeSUT(storeURL: storeURL)

        try? "invalid-json".data(using: .utf8)?.write(to: storeURL)

        self.assertThatRetrieveDeliversErrorOnRetrievalFailure(on: sut)
    }

    func test_retrieve_deliversFailure_onRetrievalError_withoutSideEffects() {
        let storeURL = self.testSpecificStoreURL()
        let sut = self.makeSUT(storeURL: storeURL)

        try? "invalid-json".data(using: .utf8)?.write(to: storeURL)

        self.assertThatRetrieveDeliversFailureOnRetrievalErrorWithoutSideEffects(on: sut)
    }

    func test_insert_deliversNoError_onEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoError_onNonEmptyCache() {
        let sut = self.makeSUT()

        self.assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_uponNonEmptyCache_overridesCache_withoutSideEffects() {
        let sut = self.makeSUT()

        self.assertThatInsertUponNonEmptyCacheOverridesCacheWithoutSideEffects(on: sut)
    }

    func test_insert_deliversError_onInsertionFailure() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = self.makeSUT(storeURL: invalidStoreURL)

        self.assertThatInsertDeliversErrorOnInsertionFailure(on: sut)
    }

    func test_insert_deliversError_onInsertionFailure_withoutSideEffects() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = self.makeSUT(storeURL: invalidStoreURL)

        self.assertThatInsertDeliversErrorOnInsertionFailureWithoutSideEffects(on: sut)
    }

    func test_delete_emtpyCache_completesWithoutError() {
        let sut = self.makeSUT()

        self.assertThatDeleteEmtpyCacheCompletesWithoutError(on: sut)
    }

    func test_delete_emtpyCache_hasNoSideEffects() {
        let sut = self.makeSUT()

        self.assertThatDeleteEmtpyCacheHasNoSideEffects(on: sut)
    }

    func test_delete_nonEmptyCache_deletesExistingCache() {
        let sut = self.makeSUT()

        self.assertThatDeleteNonEmptyCacheDeletesExistingCache(on: sut)
    }

    func test_delete_nonEmptyCache_deletesExistingCache_withoutSideEffects() {
        let sut = self.makeSUT()

        self.assertThatDeleteNonEmptyCacheDeletesExistingCacheWithoutSideEffects(on: sut)
    }

    func test_delete_deliversError_onDeletionFailure() {
        let noDeletePermissionURL = self.documentsDirectoryURL()
        let sut = self.makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = self.deleteCache(using: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error, received no error instead")
    }

    func test_delete_deliversError_onDeletionFailure_withoutSideEffects() {
        let noDeletePermissionURL = self.documentsDirectoryURL()
        let sut = self.makeSUT(storeURL: noDeletePermissionURL)

        self.deleteCache(using: sut)
        self.expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = self.makeSUT()

        self.assertThatStoreSideEffectsRunSerially(on: sut)
    }

    // MARK: Private methods

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? self.testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func setupEmptyStoreState() {
        self.deleteStoreArtifacts()
    }

    private func removeStoreSideEffects() {
        self.deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

}
