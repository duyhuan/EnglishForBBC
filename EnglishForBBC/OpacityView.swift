//
//  OpacityView.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/19/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class OpacityView: UIView {
    
    override func awakeFromNib() {
        self.alpha = 0
    }

    class func instanceFromNib() -> OpacityView {
        return UINib(nibName: "OpacityView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! OpacityView
    }
    
    func showInView(view: UIView) -> Void {
        //
        view.addSubview(self)
        self.frame = view.frame
//        self.frame = self.frame
        // update fram
//        var frame = self.frame
//        frame.origin.x = view.frame.size.width
//        self.frame = frame
    }

}
