//
//  ViewController.swift
//  Player
//
//  Created by Duy Huan on 5/10/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var yearCollectionView: UICollectionView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var player = AVPlayer()
    var isPlay: Bool = false
    var isRepeat: Bool = false
    var isExchange: Bool = true
    var isLike: Bool = false
    var audio_linkString = "http://46.101.217.198/downloads.bbc.co.uk/learningenglish/intermediate/unit15/b2_u15_6min_vocab_discourse_markers_download.mp3"
    var id: Int = 0
    var year: Int = 2017
    var firstYearCollectionView: Bool = true
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    var timerUpdateCurrentTime = Timer()
    var timerShowDuration = Timer()
    
    var minutes: Int!
    var seconds: Int!
    var duration: Double!
    var firstPlay: Bool = true
    
    var arrName: [String] = [String]()
    var arrAudio_link: [String] = [String]()
    var arrImage_link: [String] = [String]()
    var arrDesc: [String] = [String]()
    var arrLyrics: [String] = [String]()
    var arrVoc: [String] = [String]()
    var vocAndMean: [[String]] = [[String]]()
    
    var playerMini: PlayerMini?
    
    var playingIndexPath: IndexPath = IndexPath()
    var indexPathSelected: IndexPath = IndexPath()
    
    let topicModel = TopicModel()
    let managerAPI = ManagerAPI()
    
    var menu: Menu?
    var menuModel: [[MenuModel]] = [[MenuModel]]()
    var arrayTitleOfSection: [String] = [String]()
    var arrYear: [Int] = [2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008]
    
    let heightSectionHeaderMenu: CGFloat = 15.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataMenuModel()
        
        menu = Menu.instanceFromNibMenu()
        
        playerMini = PlayerMini.instanceFromNib()
        
        playerMini?.timeSlider.isEnabled = false
        
        playerMini?.timeSlider.setThumbImage(UIImage(named: "PlayerMain-icon-lineplaying.png"), for: UIControlState.normal)
        playerMini?.timeSlider.setThumbImage(UIImage(named: "PlayerMain-icon-lineplaying.png"), for: UIControlState.highlighted)
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
        
        playerMini?.playMiniPlayButton.addTarget(self, action: #selector(handlePlayMiniPlayButton), for: .touchUpInside)
        
        playerMini?.playMainPlayButton.addTarget(self, action: #selector(handlePlayMainPlayButton), for: .touchUpInside)
        
        playerMini?.repeatButton.addTarget(self, action: #selector(handleRepeatButton), for: .touchUpInside)
        
        playerMini?.exchangeButton.addTarget(self, action: #selector(handleExchangeButton), for: .touchUpInside)
        
        playerMini?.timeSlider.addTarget(self, action: #selector(handleTimeSlider), for: .valueChanged)
        
        playerMini?.nextMainPlayButton.addTarget(self, action: #selector(handleNextMainPlayButton), for: .touchUpInside)
        
        playerMini?.preMainPlayButton.addTarget(self, action: #selector(handlePreMainPlayButton), for: .touchUpInside)
        
        menu?.menuTableView.dataSource = self
        menu?.menuTableView.delegate = self
        playerMini?.vocTableView.dataSource = self
        playerMini?.vocTableView.delegate = self
        playerMini?.playListSongTableView.dataSource = self
        playerMini?.playListSongTableView.delegate = self
        
        playerMini?.vocTableView.estimatedRowHeight = 100.0
        playerMini?.vocTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 100.0
        homeTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func getDataMenuModel() {
        menuModel = [
            [
                MenuModel(menuIconImage: "Menu-icon-conversation.png", menuLabel: "English Conversation"),
                MenuModel(menuIconImage: "Menu-icon-new-report.png", menuLabel: "New Report"),
                MenuModel(menuIconImage: "Menu-icon-express.png", menuLabel: "Express English")
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-we-speak.png", menuLabel: "The English We Speak"),
                MenuModel(menuIconImage: "Menu-icon-words.png", menuLabel: "Words In The News"),
                MenuModel(menuIconImage: "Menu-icon-lingo.png", menuLabel: "LingoHack"),
                MenuModel(menuIconImage: "Menu-icon-University.png", menuLabel: "English At University"),
                MenuModel(menuIconImage: "Menu-icon-work.png", menuLabel: "English At Work")
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-6English.png", menuLabel: "6 Minute English"),
                MenuModel(menuIconImage: "Menu-icon-6Grammar.png", menuLabel: "6 Minute Grammar"),
                MenuModel(menuIconImage: "Menu-icon-6Vocabulary.png", menuLabel: "6 Minute Vocabulary"),
                MenuModel(menuIconImage: "Menu-icon-Review.png", menuLabel: "New Review"),
                MenuModel(menuIconImage: "Menu-icon-Drama.png", menuLabel: "Drama"),
                ],
            [
                MenuModel(menuIconImage: "Menu-icon-Flashcard.png", menuLabel: "Vocabulary FlashCards"),
                MenuModel(menuIconImage: "Menu-icon-VocaQuiz.png", menuLabel: "Vocabulary Quiz"),
                MenuModel(menuIconImage: "Menu-icon-pronuncation.png", menuLabel: "Pronunciation")
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-MyPlaylist.png", menuLabel: "My Playlist"),
                MenuModel(menuIconImage: "Menu-icon-downloaded.png", menuLabel: "Downloaded")
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-Upgrade.png", menuLabel: "Upgrade Pro Version"),
                MenuModel(menuIconImage: "Menu-icon-Feedback.png", menuLabel: "Feedback for Us"),
                MenuModel(menuIconImage: "Menu-icon-Setting.png", menuLabel: "Setting"),
                MenuModel(menuIconImage: "Menu-icon-rate.png", menuLabel: "Rate me 5-stars")
            ]
        ]
        
        arrayTitleOfSection = ["BEGINER", "INTERMEDIATE", "ADVANCED", "PRATICE", "PLAYLIST", "ABOUT"]
    }
    
    func handleLyricSong(lyris_string_url: String) {
        let messageURL = URL(string: lyris_string_url)
        let dataTask = URLSession.shared.dataTask(with: messageURL!) { (data, urlResponse, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200 {
                guard let result = data else { return }
                let content = String(data: result, encoding: .utf8)
                let attrStr = try! NSAttributedString(
                    data: (content?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                DispatchQueue.main.async {
                    self.playerMini?.lyricsTextView.attributedText = attrStr
                }
                
            }
            
        }
        dataTask.resume()
    }
    
    func handlePlayMiniPlayButton() {
        handlePlayButton()
    }
    
    func handlePlayMainPlayButton() {
        handlePlayButton()
    }
    
    func handleRepeatButton() {
        if isRepeat {
            playerMini?.repeatButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-off.png"), for: .normal)
            isRepeat = false
            
        } else {
            playerMini?.repeatButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-on.png"), for: .normal)
            isRepeat = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleExchangeButton() {
        if isExchange {
            playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-off.png"), for: .normal)
            isExchange = false
        } else {
            playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-on.png"), for: .normal)
            isExchange = true
        }
    }
    
    func handleTimeSlider() {
        player.seek(to: CMTime(seconds: Double((playerMini?.timeSlider.value)! * Float((player.currentItem?.duration.seconds)!)) , preferredTimescale: 1))
        
        let timeCurrent = (player.currentItem?.currentTime().seconds)!
        let currentSeconds = Int(timeCurrent) % 60
        let currentMinutes = Int(timeCurrent / 60)
        playerMini?.currentTimeLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
    }
    
    func handleNextMainPlayButton() {
        if playingIndexPath.row >= arrAudio_link.count - 2 {
            playerMini?.nextMainPlayButton.isEnabled = false
            
        } else {
            playerMini?.nextMainPlayButton.isEnabled = true
        }
        
        playerMini?.preMainPlayButton.isEnabled = true
        let newPlayingIndexPath = IndexPath(row: playingIndexPath.row + 1, section: 0)
        self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
    }
    
    func handlePreMainPlayButton() {
        if playingIndexPath.row <= 1 {
            playerMini?.preMainPlayButton.isEnabled = false
        } else {
            playerMini?.preMainPlayButton.isEnabled = true
        }
        
        playerMini?.nextMainPlayButton.isEnabled = true
        let newPlayingIndexPath = IndexPath(row: playingIndexPath.row - 1, section: 0)
        self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerMini?.showInView(view: self.view)
        self.menu?.showInView(view: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        arrName.removeAll()
        arrAudio_link.removeAll()
        arrImage_link.removeAll()
        arrDesc.removeAll()
        arrLyrics.removeAll()
        arrVoc.removeAll()
        vocAndMean.removeAll()
        
        let str = "{\"jsonrpc\":\"2.0\",\"method\":\"bbc_english.category.getSongFull\",\"id\":\"gtl_3\",\"params\":{\"id\": \(id),\"year\":\(year)},\"apiVersion\": \"v1\"}"
        
        // create post request
        guard let url = URL(string: baseAPI) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // content-type
        let headers: Dictionary = ["Content-Type": "application/json"]
        request.allHTTPHeaderFields = headers
        
        // insert json data to the request
        let data_body = str.data(using: .utf8)
        request.httpBody = data_body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let result = responseJSON["result"] {
                    if let resultCategory = result as? [String: Any] {
                        if let resultData = resultCategory["data"] {
                            
                            if let result = resultData as? [[String: Any]] {
                                
                                for index in result {
                                    
                                    self.topicModel.name = index["name"] as! String
                                    self.topicModel.audio_link = index["audio_link"] as! String
                                    self.topicModel.image_link = index["image_link"] as! String
                                    self.topicModel.desc = index["desc"] as! String
                                    if let index = index["html_link"] as? String, !index.isEmpty {
                                        self.topicModel.html_link = index
                                    }
                                    if let index = index["voc"] as? String {
                                        self.topicModel.voc = index
                                    }
                                    
                                    self.arrName.append(self.topicModel.name)
                                    self.arrAudio_link.append(self.topicModel.audio_link)
                                    self.arrImage_link.append(self.topicModel.image_link)
                                    self.arrDesc.append(self.topicModel.desc)
                                    self.arrLyrics.append(self.topicModel.html_link)
                                    self.arrVoc.append(self.topicModel.voc)
                                }
                                
                                DispatchQueue.main.async {
                                    self.homeTableView.reloadData()
                                    self.playerMini?.vocTableView.reloadData()
                                    self.playerMini?.playListSongTableView.reloadData()
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            
        }
        
        task.resume()
        
        //        if let url = URL(string: arrAudio_link[numberMp3]) {
        //            player = AVPlayer(url: url)
        //        }
        
    }
    
    func playLocal() {
        let audioName = URL(string: audio_linkString)?.lastPathComponent
        let audioPathString = "\(path)/\(audioName!)"
        let pathAudio = URL(fileURLWithPath: audioPathString)
        let playerItem = AVPlayerItem(url: pathAudio)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0
        player.volume = 0.5
    }
    
    func playOnline() {
        let audio_linkUrl = URL(string: audio_linkString)
        player = AVPlayer(url: audio_linkUrl!)
        player.rate = 1.0
        player.volume = 0.5
    }
    
    func handlePlayButton() {
        playerMini?.timeSlider.isEnabled = true
        
        if isPlay {
            timerUpdateCurrentTime.invalidate()
            player.pause()
            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
            isPlay = false
        } else {
            handlePlaying()
        }
    }
    
    func handlePlaying() {
        let audioName = URL(string: audio_linkString)?.lastPathComponent
        
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(audioName!)?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            playLocal()
        } else {
            playOnline()
        }
        player.play()
        
        playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
        isPlay = true
        playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
        timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playerDidFinishPlaying() {
        if isRepeat {
            DispatchQueue.main.async {
                self.player.seek(to: kCMTimeZero)
                self.player.play()
            }
        } else {
            self.playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
            player.seek(to: kCMTimeZero)
            player.pause()
            isPlay = false
        }
    }
    
    func showDuration() {
        duration = (player.currentItem?.duration.seconds)!
        guard !(duration.isNaN || duration.isInfinite) else {return}
        minutes = Int(duration) / 60
        seconds = Int(duration) - minutes * 60
        playerMini?.timeTotalLabel.text = String(format: "%02d:%02d", minutes, seconds)
        if duration != nil {
            timerShowDuration.invalidate()
        }
    }
    
    func updateCurrentTime() {
        let timeCurrent = (player.currentItem?.currentTime().seconds)!
        let currentSeconds = Int(timeCurrent) % 60
        let currentMinutes = Int(timeCurrent / 60)
        duration = (player.currentItem?.duration.seconds)!
        playerMini?.currentTimeLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
        playerMini?.timeSlider.value = Float(timeCurrent / duration)
    }
    
    @IBAction func handleDownloadButton(_ sender: UIButton) {
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let audioName = URL(string: audio_linkString)?.lastPathComponent
        let destinationFileUrl = documentsUrl.appendingPathComponent(audioName!)
        
        //Create URL to the source file you want to download
        
        let fileURL = URL(string: audio_linkString)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@")
            }
        }
        task.resume()
    }
    
    func handlePressHomeLikeButton(sender: UIButton) {
        if !isLike {
            sender.setBackgroundImage(UIImage(named: "Home-button-like-on.png"), for: .normal)
            isLike = true
        } else {
            sender.setBackgroundImage(UIImage(named: "Home-button-like-off.png"), for: .normal)
            isLike = false
        }
    }
    
    @IBAction func handleShowMenuButton(_ sender: UIButton) {
        self.menu?.openMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

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
            
            cell.iconMusicImageView.image = UIImage(named: "PlayerMain-icon-Music.png")
            let itemArrName = arrName[indexPath.row]
            cell.nameSongLabel.text = itemArrName
            
            return cell
        } else if tableView == homeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell", for: indexPath) as! TopicTableViewCell
            cell.homeLikeButton.tag = indexPath.row + 100
            cell.homeLikeButton.addTarget(self, action: #selector(handlePressHomeLikeButton), for: .touchUpInside)
            let itemArrImage_link = arrImage_link[indexPath.row]
            let urlImage = URL(string: itemArrImage_link)
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: urlImage!)
                    DispatchQueue.main.async {
                        cell.homeImage.image = UIImage(data: data)
                    }
                } catch {
                    print(error)
                }
            }
            
            cell.homeImage.image = UIImage(named: itemArrImage_link)
            let itemArrName = arrName[indexPath.row]
            cell.homeNameSongLabel.text = itemArrName
            let itemArrDesc = arrDesc[indexPath.row]
            cell.homeDescSongLabel.text = itemArrDesc
            
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == playerMini?.playListSongTableView {
            return 45.0
        } else if tableView == homeTableView {
            return 200.0
        } else if tableView == playerMini?.vocTableView {
            return UITableViewAutomaticDimension
        } else { //if tableView == menu?.menuTableView {
            return 25.0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == playerMini?.playListSongTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? PlayListSongTableViewCell else {return}
            cell.musicPlayingImageView.image = UIImage(named: "PlayerMain-icon-MusicPlaying.png")
            playingIndexPath = indexPath
            
            handleLyricSong(lyris_string_url: arrLyrics[indexPath.row])
            playerMini?.nameSongOnTopLabel.text = arrName[indexPath.row]
            
            player.pause()
            audio_linkString = arrAudio_link[indexPath.row]
            handlePlaying()
        } else if tableView == homeTableView {
            print("aaaaaaaaa")
            playerMini?.displayBottom(view: self.view)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? TopicTableViewCell else {return}
            
            let itemArrVoc = arrVoc[indexPath.row]
            vocAndMean = topicModel.handleVoc(voc: itemArrVoc)
            playerMini?.vocTableView.reloadData()
            
            playerMini?.playerMiniNameSongLabel.text = cell.homeNameSongLabel.text
            
            handleLyricSong(lyris_string_url: arrLyrics[indexPath.row])
            playerMini?.nameSongOnTopLabel.text = arrName[indexPath.row]
            
            player.pause()
            audio_linkString = arrAudio_link[indexPath.row]
            handlePlaying()
        } else if tableView == menu?.menuTableView {
            guard let cell = tableView.cellForRow(at: indexPath) as? MenuTableViewCell else {return}
            if cell.menuLabel.text == "Setting" {
                if let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
                    navigationController?.pushViewController(settingVC, animated: true)
                }
            } else {
                id = managerAPI.getIDTopic(topicName: cell.menuLabel.text!)
                arrYear = managerAPI.getArrYearOfTopic(id: id)
                
                firstYearCollectionView = true
                yearCollectionView.reloadData()
                self.getData()
                homeTableView.reloadData()
                
                menu?.handleSelectedAndHideMenu()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PlayListSongTableViewCell {
            cell.musicPlayingImageView.image = UIImage(named: "")
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrYear.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearCollectionViewCell.identifier(), for: indexPath) as! YearCollectionViewCell
        
        cell.setYearLabelText(text: String(arrYear[indexPath.row]))
        cell.setYearLabelColor(color: UIColor.lightGray)
        cell.setIndicatorViewColor(color: UIColor.white)
        
        if firstYearCollectionView {
            if indexPath.row == 0 {
                cell.setIndicatorViewColor(color: UIColor.red)
            }
            firstYearCollectionView = false
        }
        
        if indexPath == indexPathSelected {
            cell.setYearLabelColor(color: UIColor.black)
            cell.setIndicatorViewColor(color: UIColor.red)
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YearCollectionViewCell {
            indexPathSelected = indexPath
            cell.setIndicatorViewColor(color: UIColor.red)
            cell.setYearLabelColor(color: UIColor.black)
            collectionView.reloadData()
            year = arrYear[indexPath.row]
            getData()
            homeTableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YearCollectionViewCell {
            cell.setIndicatorViewColor(color: UIColor.white)
            cell.setYearLabelColor(color: UIColor.lightGray)
        }
    }
}

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
}
