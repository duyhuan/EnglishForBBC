//
//  Menu.swift
//  Player
//
//  Created by Duy Huan on 5/15/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import Foundation
import UIKit

protocol ProtocolDelegate {
    func handleAlphaOpacityView(alpha: CGFloat)
}

class Menu: UIView {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var rightView: UIView!
    
    var delegate: ProtocolDelegate?
    
    let height_menu: CGFloat = 50.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(hideMenu))
        swipeLeft.direction = .left
        rightView.addGestureRecognizer(swipeLeft)
    }
    
    func setFrame(view: UIView) {
        self.frame.size = view.frame.size
        rightView.frame.size.width = view.frame.width - 50.0
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
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.x = 0 - self.frame.width
            self.delegate?.handleAlphaOpacityView(alpha: 0)
        }
    }
    
}
