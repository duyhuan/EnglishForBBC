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
            return 30.0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == playerMini?.playListSongTableView {
            if let cell_select_from_home = tableView.cellForRow(at: playingIndexPath) as? PlayListSongTableViewCell {
                cell_select_from_home.musicPlayingImageView.image = nil
            }
            
            guard let cell = tableView.cellForRow(at: indexPath) as? PlayListSongTableViewCell else {return}
            cell.musicPlayingImageView.image = UIImage(named: "PlayerMain-icon-MusicPlaying.png")
            
            let itemArrVoc = arrVoc[indexPath.row]
            vocAndMean = topicModel.handleVoc(voc: itemArrVoc)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
            }
            playingIndexPath = indexPath
            
            handleLyricSong(lyris_string_url: arrLyrics[indexPath.row])
            playerMini?.nameSongOnTopLabel.text = arrName[indexPath.row]
            
            player.pause()
            audio_linkString = arrAudio_link[indexPath.row]
            handlePlaying()
        } else if tableView == homeTableView {
            playingIndexPath.row = indexPath.row
            UIView.animate(withDuration: 0.3, animations: {
                self.homeTableViewSpaceBottomConstraint.constant = 60.0
                self.view.layoutIfNeeded()
            })
            playerMini?.displayBottom(view: self.view)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? TopicTableViewCell else {return}
            
            let itemArrVoc = arrVoc[indexPath.row]
            vocAndMean = topicModel.handleVoc(voc: itemArrVoc)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
                self.playerMini?.playListSongTableView.reloadData()
            }
            
            playerMini?.playerMiniNameSongLabel.text = cell.homeNameSongLabel.text
            
            handleLyricSong(lyris_string_url: arrLyrics[indexPath.row])
            playerMini?.nameSongOnTopLabel.text = arrName[indexPath.row]
            
            player.pause()
            audio_linkString = arrAudio_link[indexPath.row]
            handlePlaying()
            handleRepeatExchange()
        } else if tableView == menu?.menuTableView {
            indexPathSelected = IndexPath(row: 0, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? MenuTableViewCell else {return}
            if cell.menuLabel.text == TopicName.VocabularyFlashCards.rawValue{
                
            } else if cell.menuLabel.text == TopicName.VocabularyQuiz.rawValue {
                
            } else if cell.menuLabel.text == TopicName.Pronunciation.rawValue {
                
            } else if cell.menuLabel.text == TopicName.MyPlaylist.rawValue {
                hideMenu()
                id = -1
                year = 0
                arrYear.removeAll()
                arrName.removeAll()
                arrDesc.removeAll()
                arrImage_link.removeAll()
                
                for (_ , value) in dictFavorite! {
                    let valueItem = value as! [String: Any]
                    arrName.append(valueItem["name"]! as! String)
                    arrDesc.append(valueItem["desc"]! as! String)
                    arrImage_link.append(valueItem["img"]! as! String)
                }
                DispatchQueue.main.async {
                    self.yearCollectionView.reloadData()
                    self.homeTableView.reloadData()
                }
                
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
                hideMenu()
                
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
