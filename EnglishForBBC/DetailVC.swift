//
//  DetailVC.swift
//  Player
//
//  Created by Duy Huan on 5/11/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class DetailVC: UITableViewCell {

    @IBOutlet weak var musicImg: UIImageView!
    @IBOutlet weak var nameSongLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
