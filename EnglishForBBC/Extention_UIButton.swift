//
//  Extention_UIButton.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/24/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class Extention_UIButton: UIButton {

    func player_mini_pause() -> UIImage? {
        if let img = UIImage(named: "PlayerMini-icon-pause.png") {
            return img
        }
        return nil
    }
    
    func player_mini_playing() {
        self.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
    }
    
    func player_main_pause() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-pause.png"), for: .normal)
    }
    
    func player_main_playing() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
    }
    
    func player_main_down_off() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-down-off.png"), for: .normal)
    }
    
    func player_main_down_on() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-down-on.png"), for: .normal)
    }
    
    func player_main_exchange_off() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-off.png"), for: .normal)
    }
    
    func player_main_exchange_on() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-on.png"), for: .normal)
    }
    
    func player_main_like_off(){
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-off.png"), for: .normal)
    }
    
    func player_main_like_on() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
    }
    
    func player_main_repeat_off() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-off.png"), for: .normal)
    }
    
    func player_main_repeat_on() {
        self.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-on.png"), for: .normal)
    }

}
