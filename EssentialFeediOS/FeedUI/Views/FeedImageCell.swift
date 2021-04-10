//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-15.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    @IBOutlet private(set) public var descriptionLabel: UILabel!

    var retryButtonAction: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        self.retryButtonAction?()
    }
}

