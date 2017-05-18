//
//  SettingViewController.swift
//  Player
//
//  Created by Duy Huan on 5/17/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    let menu = Menu()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleOpenMenuButton(_ sender: UIButton) {
        menu.openMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
