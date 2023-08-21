//
//  ContentTableViewCell.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import UIKit
import Kingfisher

final class ContentTableViewCell: UITableViewCell {

    @IBOutlet private weak var cameraImageView: UIImageView!
    @IBOutlet private weak var favoriteImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dooreStatus: UIImageView!
    
}

//MARK: - Private methods
private extension ContentTableViewCell {
    private func checkingFavorites(isFavorite: Bool) {
        if isFavorite {
            favoriteImageView.isHidden = false
        } else {
            favoriteImageView.isHidden = true
        }
    }
}

//MARK: - Public methods
extension ContentTableViewCell {
    func setupCameraCell(model: CameraModel) {
        cameraImageView.kf.setImage(with: URL(string: model.snapshot))
        checkingFavorites(isFavorite: model.favorites)
        titleLabel.text = model.name
    }
    
    func setupDoorCell(model: DoorsDataModel) {
        cameraImageView.kf.setImage(with: URL(string: model.snapshot ?? ""))
        checkingFavorites(isFavorite: model.favorites)
        titleLabel.text = model.name
        dooreStatus.isHidden = false
    }
}


