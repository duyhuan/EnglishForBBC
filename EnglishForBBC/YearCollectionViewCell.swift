//
//  MenuCollectionViewCell.swift
//  Player
//
//  Created by Duy Huan on 5/16/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class YearCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    static func identifier() -> String {
        return "menuCollectionViewCell"
    }
    
    func setYearLabelText(text: String) {
        self.yearLabel.text = text
    }
    
    func setYearLabelColor(color: UIColor) {
        self.yearLabel.textColor = color
    }
    
    func setIndicatorViewColor(color: UIColor) {
        self.indicatorView.backgroundColor = color
    }
    
}
