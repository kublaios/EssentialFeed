//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Kubilay Erdogan on 2021-04-11.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.simulate(event: .valueChanged)
    }
}
