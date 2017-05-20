//
//  SettingView.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/18/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import Foundation
import UIKit

class SettingView: UIView {
    
    let menu = Menu()
    
    override func awakeFromNib() {
        self.alpha = 0
    }
    
    class func instanceFromNib() -> SettingView {
        return UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    }
    
    @IBAction func handleOpenMenuView(_ sender: UIButton) {
        self.menu.alpha = 1
        self.hideSettingView()
    }
    
    func showInView(view: UIView) -> Void {
        //
        view.addSubview(self)
        
        // update fram
        var frame = self.frame
        frame.origin.x = view.frame.size.width
        self.frame = frame
    }
    
    func openSettingView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.frame.origin.x = 0
            self.frame = self.frame
        }
    }
    
    func hideSettingView() {
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 0
            self.frame.origin.x = (self.superview?.bounds.width)!
        }
    }
    
}
