//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Kubilay Erdogan on 2021-04-10.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
