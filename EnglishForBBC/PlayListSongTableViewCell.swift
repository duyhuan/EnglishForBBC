//
//  PlayListSongTableViewCell.swift
//  Player
//
//  Created by Duy Huan on 5/13/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class PlayListSongTableViewCell: UITableViewCell {

    @IBOutlet weak var iconMusicImageView: UIImageView!
    @IBOutlet weak var nameSongLabel: UILabel!
    @IBOutlet weak var musicPlayingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func identifier() -> String {
        return "PlayListSongTableViewCell"
    }
    
}
