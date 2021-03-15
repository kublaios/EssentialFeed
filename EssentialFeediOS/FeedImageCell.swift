//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-03-15.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView.init()
    public let locationLabel = UILabel.init()
    public let descriptionLabel = UILabel.init()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView.init()

    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton.init()
        button.addTarget(self, action: #selector(self.retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var retryButtonAction: (() -> Void)?

    @objc private func retryButtonTapped() {
        self.retryButtonAction?()
    }
}

