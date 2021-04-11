//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit

extension UIButton {
    func simulateTap() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
