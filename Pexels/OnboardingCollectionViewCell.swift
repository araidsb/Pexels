//
//  OnboardingCollectionViewCell.swift
//  Pexels
//
//  Created by Арай Дуйсебекова on 28.05.2023.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String = "OnboardingCollectionViewCell"
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var innerStackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(onboardingModel: OnboardingModel) {
        imageView.image = UIImage(named: onboardingModel.imageName)
        titleLabel.text = onboardingModel.title
        subTitleLabel.text = onboardingModel.subtitle
    }

}
