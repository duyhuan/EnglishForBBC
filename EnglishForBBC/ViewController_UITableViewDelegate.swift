//
//  ViewController_Delegate.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/23/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//
import Foundation
import UIKit

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == playerMini?.playListSongTableView {
            return 45.0
        } else if tableView == homeTableView {
            return 200.0
        } else if tableView == playerMini?.vocTableView {
            return UITableViewAutomaticDimension
        } else { //if tableView == menu?.menuTableView {
            return 45.0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == playerMini?.playListSongTableView {
            
            timerShowDuration.invalidate()
            timerUpdateCurrentTime.invalidate()
            playerMini?.setTimeTotalLabel(text: "00:00")
            
            playerMini?.playerMiniLikeButton.setImage(UIImage(named: "PlayerMain-icon-like-off.png"), for: .normal)
            if let cell_select_from_home = tableView.cellForRow(at: playingIndexPath) as? PlayListSongTableViewCell {
                cell_select_from_home.musicPlayingImageView.image = nil
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) as? PlayListSongTableViewCell else {return}
            cell.musicPlayingImageView.image = UIImage(named: "PlayerMain-icon-MusicPlaying.png")
            
            let itemArrVoc = currentListData?[indexPath.row].voc
            vocAndMean = topicModel.handleVoc(voc: itemArrVoc!)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
            }
            playingIndexPath = indexPath
            
            handleLyricSong(lyris_string_url: (currentListData?[indexPath.row].html_link)!)
            playerMini?.nameSongOnTopLabel.text = currentListData?[indexPath.row].name
            
            player.pause()
            audio_linkString = (currentListData?[indexPath.row].audio_link)!
            handlePlaying()
            
            if let url = URL(string: (currentListData?[indexPath.row].image_link)!) {
                do {
                    let data = try Data(contentsOf: url)
                    playerMini?.playerMiniAvatarImageView.image = UIImage(data: data)
                } catch {
                    print(error)
                }
            }
            
            if let dict = dictFavorite {
                for (_, value) in dict {
                    let itemValue = value as? [String: Any]
                    if cell.nameSongLabel.text! == itemValue?["name"]! as? String {
                        playerMini?.playerMiniLikeButton.setImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
                    }
                }
            }
            
        } else if tableView == homeTableView {
            
            timerShowDuration.invalidate()
            timerUpdateCurrentTime.invalidate()
            playerMini?.setTimeTotalLabel(text: "00:00")
            
            playingIndexPath.row = indexPath.row
            
            self.playerMini?.playingIndexPath = playingIndexPath
            
            UIView.animate(withDuration: 0.3, animations: {
                self.homeTableViewSpaceBottomConstraint.constant = 60.0
                self.view.layoutIfNeeded()
            })
            playerMini?.displayBottom(view: self.view)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? TopicTableViewCell else {return}
            
            let itemArrVoc = currentListData?[indexPath.row].voc
            vocAndMean = topicModel.handleVoc(voc: itemArrVoc!)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
                self.playerMini?.playListSongTableView.reloadData()
            }
            
            playerMini?.playerMiniNameSongLabel.text = cell.homeNameSongLabel.text
            
            handleLyricSong(lyris_string_url: (currentListData?[indexPath.row].html_link)!)
            playerMini?.nameSongOnTopLabel.text = currentListData?[indexPath.row].name
            
            if let url = URL(string: (currentListData?[indexPath.row].image_link)!) {
                do {
                    let data = try Data(contentsOf: url)
                    playerMini?.playerMiniAvatarImageView.image = UIImage(data: data)
                } catch {
                    print(error)
                }
            }
            
            player.pause()
            audio_linkString = (currentListData?[indexPath.row].audio_link)!
            handlePlaying()
            
            if cell.homeLikeButton.currentImage == UIImage(named: "Home-button-like-on.png") {
                player_main_like_on()
            } else {
                player_main_like_off()
            }
            
            playerMini?.setFontLyricTextView()
            
        } else if tableView == menu?.menuTableView {
            yearCollectionViewHeightConstraint.constant = 40
            yearCollectionView.reloadData()
            indexPathSelected = IndexPath(row: 0, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? MenuTableViewCell else {return}
            if cell.menuLabel.text == TopicName.VocabularyFlashCards.rawValue{
                
            } else if cell.menuLabel.text == TopicName.VocabularyQuiz.rawValue {
                
            } else if cell.menuLabel.text == TopicName.Pronunciation.rawValue {
                
            } else if cell.menuLabel.text == TopicName.MyPlaylist.rawValue {
                menu?.hideMenu()
//                id = -1
//                year = 0
                arrYear.removeAll()
                
//                var favoriteListData = [PostModel]()
//                for (_ , value) in dictFavorite! {
//                    let favorite = PostModel()
//                    let valueItem = value as! [String: Any]
//                    favorite.name = valueItem["name"] as! String
//                    favorite.desc = valueItem["desc"] as! String
//                    favorite.image_link = valueItem["image_link"] as! String
//                    favorite.voc = valueItem["voc"] as! String
//                    favorite.audio_link = valueItem["audio_link"] as! String
//                    print(favorite.audio_link)
//                    favorite.html_link = valueItem["html_link"] as! String
//                    favoriteListData.append(favorite)
//                }
//                currentListData = favoriteListData
                
                currentListData = favoriteListData
                
                self.yearCollectionView.reloadData()
                self.homeTableView.reloadData()
//                self.playerMini?.vocTableView.reloadData()
//                self.playerMini?.playListSongTableView.reloadData()
//
//                
//                yearCollectionViewHeightConstraint.constant = 0
                
            } else if cell.menuLabel.text == TopicName.Downloaded.rawValue {
                
            } else if cell.menuLabel.text == TopicName.UpgradeProVersion.rawValue {
                
            } else if cell.menuLabel.text == TopicName.FeedbackForUs.rawValue {
                
            } else if cell.menuLabel.text == TopicName.Setting.rawValue {
                settingView?.openSettingView()
            } else if cell.menuLabel.text == TopicName.RateMe.rawValue {
                
            } else {
                startAnimating()
                id = managerAPI.getIDTopic(topicName: cell.menuLabel.text!)
                arrYear = managerAPI.getArrYearOfTopic(id: id)
                
                if let firstYear = arrYear.first {
                    year = firstYear
                } else {
                    year = 0
                    stopAnimating()
                }
                
                firstYearCollectionView = true
                menu?.hideMenu()
                
                DispatchQueue.main.async {
                    self.yearCollectionView.reloadData()
                    self.getData()
                    self.homeTableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PlayListSongTableViewCell {
            cell.musicPlayingImageView.image = UIImage(named: "")
        }
    }
    
}
