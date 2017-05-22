//
//  SettingTableViewCell.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/22/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var textLabelSetting: UILabel!
    @IBOutlet weak var detailTextLabelSetting: UILabel!
    @IBOutlet weak var switchOnOff: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func identifier() -> String {
        return "SettingTableViewCell"
    }
    
    func setTextLabelSetting(text: String) {
        self.textLabel?.text = text
    }
    
    func setDetailTextLabelSetting(text: String) {
        self.detailTextLabel?.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
