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
    @IBOutlet private(set) var imageContainer: UIView!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.feedImageView.alpha = .zero
        self.imageContainer.startShimmering()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.feedImageView.alpha = .zero
        self.imageContainer.startShimmering()
    }

    func fadeIn(_ image: UIImage?) {
        self.feedImageView.image = image

        let animations: () -> Void = { [weak self] in
            self?.feedImageView.alpha = 1.0
        }

        let completion: (Bool) -> Void = { [weak self] _ in
            self?.imageContainer.stopShimmering()
        }

        UIView.animate(withDuration: 0.25,
                       delay: 1.25,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = self.bounds.width
        let height = self.bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        self.layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: self.shimmerAnimationKey)
    }

    func stopShimmering() {
        self.layer.mask = nil
    }
}
