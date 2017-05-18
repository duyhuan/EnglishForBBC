//
//  MenuTableViewCell.swift
//  Player
//
//  Created by Duy Huan on 5/15/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuIconImageView: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func identifier() -> String {
        return "MenuTableViewCell"
    }
    
    func setMenuLabel(text: String) {
        self.menuLabel.text = text
    }
    
    func setMenuIconImageView(imageName: String) {
        self.menuIconImageView.image = UIImage(named: imageName)
    }
    
}
