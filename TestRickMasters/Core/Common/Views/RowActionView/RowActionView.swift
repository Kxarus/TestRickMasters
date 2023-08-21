//
//  RowActionType.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 20.08.2023.
//

import UIKit

final class RowActionView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
}

//MARK: - Private methods
private extension RowActionView {
    private func setupView() {
        backgroundColor = .clear
        imageView.tintColor = .white
    }
}

//MARK: - Public methods
extension RowActionView {
    func configure(with type: RowActionType) {
        switch type {
        case .edit:
            imageView.image = R.image.edit()
        case .favourite:
            imageView.image = R.image.favourites()
        }
    }
}
