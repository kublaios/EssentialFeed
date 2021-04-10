//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-10.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        self.image = newImage

        if newImage != nil {
            self.alpha = .zero
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.alpha = 1.0
            }
        }
    }
}
