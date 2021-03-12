//
//  FeedViewController.swift
//  Prototype
//
//  Created by Kubilay Erdogan on 2021-03-12.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {
    private let prototypeFeed = FeedImageViewModel.prototypeFeed

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prototypeFeed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = self.prototypeFeed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        self.locationLabel.text = model.location
        self.locationLabel.isHidden = model.location == nil

        self.descriptionLabel.text = model.description
        self.descriptionLabel.isHidden = model.description == nil

        self.feedImageView.image = UIImage.init(named: model.imageName)
    }
}
