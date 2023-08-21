//
//  WithoutContentTableViewCell.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import UIKit

final class WithoutContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dooreStatus: UIImageView!

}

//MARK: - Private methods
private extension WithoutContentTableViewCell {
    
}

//MARK: - Public methods
extension WithoutContentTableViewCell {
    func setupDoorCell(model: DoorsDataModel) {
        titleLabel.text = model.name
        dooreStatus.isHidden = false
    }
}
