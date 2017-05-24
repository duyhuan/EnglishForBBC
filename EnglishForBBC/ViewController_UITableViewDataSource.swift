//
//  ViewController_DataSource.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/23/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menu?.menuTableView {
            return arrayTitleOfSection.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menu?.menuTableView {
            return menuModel[section].count
        } else if tableView == playerMini?.vocTableView {
            return vocAndMean.count
        } else {
            return arrName.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == menu?.menuTableView {
            let headerView = UIView()
            headerView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            
            let headerLabel = UILabel()
            headerLabel.text = arrayTitleOfSection[section]
            headerLabel.frame = CGRect(x: 0.0, y: 0.0, width: (menu?.menuTableView.frame.width)!, height: heightSectionHeaderMenu)
            headerLabel.textAlignment = .center
            headerLabel.font = UIFont(name: headerLabel.font.fontName, size: 12.0)
            headerLabel.font = UIFont.boldSystemFont(ofSize: headerLabel.font.pointSize)
            
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == menu?.menuTableView {
            return heightSectionHeaderMenu
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == playerMini?.playListSongTableView {
            let cell = Bundle.main.loadNibNamed("PlayListSongTableViewCell", owner: self, options: nil)?.first as! PlayListSongTableViewCell
            if indexPath.row == playingIndexPath.row {
                cell.musicPlayingImageView.image = UIImage(named: "PlayerMain-icon-MusicPlaying.png")
            }
            
            DispatchQueue.global().async {
                let itemArrName = self.arrName[indexPath.row]
                DispatchQueue.main.async {
                    cell.iconMusicImageView.image = UIImage(named: "PlayerMain-icon-Music.png")
                    cell.nameSongLabel.text = itemArrName
                }
            }
            
            return cell
        } else if tableView == homeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell", for: indexPath) as! TopicTableViewCell
            cell.homeImage.image = nil
            cell.homeNameSongLabel.text = nil
            cell.homeDescSongLabel.text = nil
            cell.homeLikeButton.setBackgroundImage(UIImage(named: "Home-button-like-off.png"), for: .normal)
            
            let urlString = self.arrImage_link[indexPath.row]
            let itemArrName = self.arrName[indexPath.row]
            let itemArrDesc = self.arrDesc[indexPath.row]
            
            cell.homeLikeButton.tag = indexPath.row
            cell.homeLikeButton.addTarget(self, action: #selector(self.handlePressHomeLikeButton), for: .touchUpInside)
            
            DispatchQueue.global().async {
                let url = URL(string: urlString)
                if let imgCache = imageCache.object(forKey: urlString as AnyObject), let nameCache = nameCache.object(forKey: itemArrName as AnyObject), let descCache = descCache.object(forKey: itemArrDesc as AnyObject) {
                    DispatchQueue.main.async {
                        cell.homeImage.image = imgCache as? UIImage
                        cell.homeNameSongLabel.text = nameCache as? String
                        cell.homeDescSongLabel.text = descCache as? String
                    }
                } else {
                    do {
                        let data = try Data(contentsOf: url!)
                        DispatchQueue.main.async {
                            cell.homeImage.image = UIImage(data: data)
                            if let img = UIImage(data: data) {
                                imageCache.setObject(img, forKey: urlString as AnyObject)
                            }
                            cell.homeNameSongLabel.text = itemArrName
                            nameCache.setObject(itemArrName as AnyObject, forKey: itemArrName as AnyObject)
                            cell.homeDescSongLabel.text = itemArrDesc
                            descCache.setObject(itemArrDesc as AnyObject, forKey: itemArrDesc as AnyObject)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                DispatchQueue.main.async {
                    for (_ , value) in self.dictFavorite! {
                        let itemValue = value as! [String: Any]
                        
                        if cell.homeNameSongLabel.text! == itemValue["name"]! as! String
//                            , self.id == itemValue["id"]! as? Int, self.year == itemValue["year"]! as? Int, cell.homeDescSongLabel.text! == itemValue["desc"]! as? String, cell.homeImage.image! == UIImage(named: (itemValue["img"]! as? String)!)
                        {
                            cell.homeLikeButton.setBackgroundImage(UIImage(named: "Home-button-like-on.png"), for: .normal)
                        }
                    }
                }
                
            }
            return cell
        } else if tableView == playerMini?.vocTableView {
            let cell = Bundle.main.loadNibNamed(VocTableViewCell.nibName(), owner: self, options: nil)?.first as! VocTableViewCell
            let itemVocAndMean = vocAndMean[indexPath.row]
            cell.setVocLabel(text: itemVocAndMean[0].uppercaseFirst)
            cell.setMeanOfVocLabel(text: itemVocAndMean[1].uppercaseFirst)
            
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed(MenuTableViewCell.identifier(), owner: self, options: nil)?.first as! MenuTableViewCell
            
            let itemMenuModel = menuModel[indexPath.section][indexPath.row]
            
            let menuLabelText = itemMenuModel.menuLabel
            let menuIconImageViewName = itemMenuModel.menuIconImage
            
            cell.setMenuLabel(text: menuLabelText)
            cell.setMenuIconImageView(imageName: menuIconImageViewName)
            
            return cell
        }
    }
}
