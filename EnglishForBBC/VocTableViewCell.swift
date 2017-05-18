//
//  VocTableViewCell.swift
//  Player
//
//  Created by Duy Huan on 5/17/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class VocTableViewCell: UITableViewCell {

    @IBOutlet weak var vocImageView: UIImageView!
    @IBOutlet weak var vocLabel: UILabel!
    @IBOutlet weak var meanOfVocLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func identifier() -> String {
        return "VocTableViewCell"
    }
    
    static func nibName() -> String {
        return "VocTableViewCell"
    }
    
    func setVocLabel(text: String) {
        self.vocLabel.text = text
    }
    
    func setMeanOfVocLabel(text: String) {
        self.meanOfVocLabel.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
