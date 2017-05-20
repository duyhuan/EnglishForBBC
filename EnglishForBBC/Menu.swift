//
//  Menu.swift
//  Player
//
//  Created by Duy Huan on 5/15/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import Foundation
import UIKit

class Menu: UIView {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var rightView: UIView!
    
    let height_menu: CGFloat = 50.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    class func instanceFromNibMenu() -> Menu {
        return UINib(nibName: "Menu", bundle: nil).instantiate(withOwner: nil, options: nil).first as! Menu
    }
    
    func showInView(view: UIView) -> Void {
        view.addSubview(self)
        
        var frame = self.frame
        frame.origin.x = 0 - view.frame.size.width
        self.frame = frame
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.x = 0
            self.frame = self.frame
        }
    }
    
}
