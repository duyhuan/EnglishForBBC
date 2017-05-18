//
//  TopicTableViewCell.swift
//  Player
//
//  Created by Duy Huan on 5/15/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class TopicTableViewCell: UITableViewCell {

    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeNameSongLabel: UILabel!
    @IBOutlet weak var homeDescSongLabel: UILabel!
    @IBOutlet weak var homeDownloadButton: UIButton!
    @IBOutlet weak var homeLikeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
