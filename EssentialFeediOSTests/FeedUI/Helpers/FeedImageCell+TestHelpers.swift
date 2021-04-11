//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !self.locationContainer.isHidden
    }

    var locationText: String? {
        return self.locationLabel.text
    }

    var descriptionText: String? {
        return self.descriptionLabel.text
    }

    var isShowingImageLoadingIndicator: Bool {
        return self.feedImageContainer.isShimmering
    }

    var renderedImageData: Data? {
        self.feedImageView.image?.pngData()
    }

    var isShowingRetryButton: Bool {
        return !self.feedImageRetryButton.isHidden
    }

    func simulateUserInitiatedRetryAction() {
        self.feedImageRetryButton.simulateTap()
    }
}
