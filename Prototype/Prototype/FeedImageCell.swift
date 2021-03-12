//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Kubilay Erdogan on 2021-03-12.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.feedImageView.alpha = .zero
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.feedImageView.alpha = .zero
    }

    func fadeIn(_ image: UIImage?) {
        self.feedImageView.image = image

        UIView.animate(withDuration: 0.3, delay: 0.3, options: []) { [weak self] in
            self?.feedImageView.alpha = 1.0
        }
    }
}
