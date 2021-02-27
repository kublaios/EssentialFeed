//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Kubilay Erdogan on 2021-02-27.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyResultOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValues_onNonEmptyCache()
    func test_retrieve_afterInsertingToEmptyCache_hasNoSideEffects()

    func test_insert_deliversNoError_onEmptyCache()
    func test_insert_deliversNoError_onNonEmptyCache()
    func test_insert_uponNonEmptyCache_overridesCache_withoutSideEffects()

    func test_delete_emtpyCache_completesWithoutError()
    func test_delete_emtpyCache_hasNoSideEffects()
    func test_delete_nonEmptyCache_deletesExistingCache()
    func test_delete_nonEmptyCache_deletesExistingCache_withoutSideEffects()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversError_onRetrievalFailure()
    func test_retrieve_deliversFailure_onRetrievalError_withoutSideEffects()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversError_onInsertionFailure()
    func test_insert_deliversError_onInsertionFailure_withoutSideEffects()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversError_onDeletionFailure()
    func test_delete_deliversError_onDeletionFailure_withoutSideEffects()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
