//
//  SearchTextCollectionViewCell.swift
//  Pexels
//
//  Created by Арай Дуйсебекова on 26.07.2023.
//

import UIKit

class SearchTextCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "SearchTextCollectionViewCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var historyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 10
    }
    
    func set(title: String) {
        historyLabel.text = title
    }

}
