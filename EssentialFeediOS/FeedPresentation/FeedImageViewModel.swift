//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-31.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    var hasLocation: Bool {
        return self.location != nil
    }
}
