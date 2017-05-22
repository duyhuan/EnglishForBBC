//
//  ViewController.swift
//  Player
//
//  Created by Duy Huan on 5/10/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit
import AVFoundation

let arrNameCache = NSCache<AnyObject, AnyObject>()
let arrAudio_linkCache = NSCache<AnyObject, AnyObject>()
let arrImage_linkCache = NSCache<AnyObject, AnyObject>()
let arrDescCache = NSCache<AnyObject, AnyObject>()
let arrLyricsCache = NSCache<AnyObject, AnyObject>()
let arrVocCache = NSCache<AnyObject, AnyObject>()
let vocAndMeanCache = NSCache<AnyObject, AnyObject>()
let imageCache = NSCache<AnyObject, AnyObject>()
let nameCache = NSCache<AnyObject, AnyObject>()
let descCache = NSCache<AnyObject, AnyObject>()

class ViewController: UIViewController {
    
    @IBOutlet weak var yearCollectionView: UICollectionView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var homeTableViewSpaceBottomConstraint: NSLayoutConstraint!
    
    var player = AVPlayer()
    var isPlay: Bool = false
    var isRepeat: Bool = false
    var isExchange: Bool = false
    var isLike: Bool = false
    var audio_linkString = ""
    var str = ""
    var isEnd: Bool = false
    
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
    
    var arrNameFavorite: [String] = [String]()
    var arrImage_linkFavorite: [String] = [String]()
    var arrDescFavorite: [String] = [String]()
    
    var dictHomeLikeButton: [Int: Int] = [Int: Int]()
    var dictYear: [Int: Int] = [Int: Int]()
    var dictID: [Int: Int] = [Int: Int]()
    var dictNameFavorite: [String: String] = [String: String]()
    var dictImage_linkFavorite: [String: String] = [String: String]()
    var dictDescFavorite: [String: String] = [String: String]()
    
    var playerMini: PlayerMini?
    let topicModel = TopicModel()
    let managerAPI = ManagerAPI()
    var menu: Menu?
    var menuModel: [[MenuModel]] = [[MenuModel]]()
    var settingView: SettingView?
    var opacityView: OpacityView?
    
    var playingIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var indexPathSelected: IndexPath = IndexPath(row: 0, section: 0)
    
    var arrayTitleOfSection: [String] = [String]()
    var arrYear: [Int] = [2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008]
    
    let heightSectionHeaderMenu: CGFloat = 15.0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var spiningActivity = MBProgressHUD()
    var refresher: UIRefreshControl?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        str = "{\"jsonrpc\":\"2.0\",\"method\":\"bbc_english.category.getSongFull\",\"id\":\"gtl_3\",\"params\":{\"id\": \(id),\"year\":\(year)},\"apiVersion\": \"v1\"}"
        
        setupRefresher()
        
        getDataMenuModel()
        
        opacityView = OpacityView.instanceFromNib()
        menu = Menu.instanceFromNibMenu()
        playerMini = PlayerMini.instanceFromNib()
        settingView = SettingView.instanceFromNib()
        
//        playerMini?.timeSlider.isEnabled = false
        
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
        playerMini?.nextMiniPlayButton.addTarget(self, action: #selector(handleNextMiniPlayButton), for: .touchUpInside)
        playerMini?.preMiniPlayButton.addTarget(self, action: #selector(handlePreMiniPlayButton), for: .touchUpInside)
        
        menu?.rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
        menu?.rightView.isUserInteractionEnabled = true
        
        menu?.menuTableView.dataSource = self
        menu?.menuTableView.delegate = self
        playerMini?.vocTableView.dataSource = self
        playerMini?.vocTableView.delegate = self
        playerMini?.playListSongTableView.dataSource = self
        playerMini?.playListSongTableView.delegate = self
        settingView?.settingTableView.dataSource = self
        settingView?.settingTableView.delegate = self
        
        playerMini?.vocTableView.estimatedRowHeight = 100.0
        playerMini?.vocTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 100.0
        homeTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menu?.frame.origin.x = 0 - (self.menu?.frame.width)!
            self.opacityView?.alpha = 0
        }
    }
    
    func setupRefresher() {
        refresher = UIRefreshControl()
        refresher?.addTarget(self, action: #selector(handleRefresherTableView), for: .valueChanged)
        refresher?.tintColor = UIColor.red
        homeTableView.addSubview(refresher!)
    }
    
    func handleRefresherTableView() {
        if year != 0 || id != -1 {
            getData()
        }
        DispatchQueue.main.async {
            self.homeTableView.reloadData()
        }
        refresher?.endRefreshing()
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.red
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        self.view.addSubview(activityIndicator)
        startAnimating()
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
        spiningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spiningActivity.label.text = "Loading"
        spiningActivity.detailsLabel.text = "Please wait"
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupActivityIndicator()
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerMini?.showInView(view: self.view)
        self.opacityView?.showInView(view: self.view)
        self.menu?.showInView(view: self.view)
        self.settingView?.showInView(view: self.view)
    }
    
    func getDataMenuModel() {
        menuModel = [
            [
                MenuModel(menuIconImage: "Menu-icon-conversation.png",  menuLabel: TopicName.EnglishConversation.rawValue),
                MenuModel(menuIconImage: "Menu-icon-new-report.png",    menuLabel: TopicName.NewReport.rawValue),
                MenuModel(menuIconImage: "Menu-icon-express.png",       menuLabel: TopicName.ExpressEnglish.rawValue)
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-we-speak.png",      menuLabel: TopicName.TheEnglishWeSpeak.rawValue),
                MenuModel(menuIconImage: "Menu-icon-words.png",         menuLabel: TopicName.WordsInTheNews.rawValue),
                MenuModel(menuIconImage: "Menu-icon-lingo.png",         menuLabel: TopicName.LingoHack.rawValue),
                MenuModel(menuIconImage: "Menu-icon-University.png",    menuLabel: TopicName.EnglishAtUniversity.rawValue),
                MenuModel(menuIconImage: "Menu-icon-work.png",          menuLabel: TopicName.EnglishAtWork.rawValue)
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-6English.png",      menuLabel: TopicName.SixMinuteEnglish.rawValue),
                MenuModel(menuIconImage: "Menu-icon-6Grammar.png",      menuLabel: TopicName.SixMinuteGrammar.rawValue),
                MenuModel(menuIconImage: "Menu-icon-6Vocabulary.png",   menuLabel: TopicName.SixMinuteVocabulary.rawValue),
                MenuModel(menuIconImage: "Menu-icon-Review.png",        menuLabel: TopicName.NewReview.rawValue),
                MenuModel(menuIconImage: "Menu-icon-Drama.png",         menuLabel: TopicName.Drama.rawValue),
                ],
            [
                MenuModel(menuIconImage: "Menu-icon-Flashcard.png",     menuLabel: TopicName.VocabularyFlashCards.rawValue),
                MenuModel(menuIconImage: "Menu-icon-VocaQuiz.png",      menuLabel: TopicName.VocabularyQuiz.rawValue),
                MenuModel(menuIconImage: "Menu-icon-pronuncation.png",  menuLabel: TopicName.Pronunciation.rawValue)
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-MyPlaylist.png",    menuLabel: TopicName.MyPlaylist.rawValue),
                MenuModel(menuIconImage: "Menu-icon-downloaded.png",    menuLabel: TopicName.Downloaded.rawValue)
            ],
            [
                MenuModel(menuIconImage: "Menu-icon-Upgrade.png",       menuLabel: TopicName.UpgradeProVersion.rawValue),
                MenuModel(menuIconImage: "Menu-icon-Feedback.png",      menuLabel: TopicName.FeedbackForUs.rawValue),
                MenuModel(menuIconImage: "Menu-icon-Setting.png",       menuLabel: TopicName.Setting.rawValue),
                MenuModel(menuIconImage: "Menu-icon-rate.png",          menuLabel: TopicName.RateMe.rawValue)
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
        if !isExchange {
            playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-on.png"), for: .normal)
            isExchange = true
        } else {
            playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-off.png"), for: .normal)
            isExchange = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleRepeatExchange() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleRepeatExchangeMusic() {
        
        if !isExchange {
            if !isRepeat {
                player.seek(to: kCMTimeZero)
                player.pause()
            } else {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        } else {
            
            
            if isEnd == true {
                playingIndexPath.row += 1
            }
            audio_linkString = arrAudio_link[playingIndexPath.row]
            let audioName = URL(string: audio_linkString)?.lastPathComponent
            
            let url = NSURL(fileURLWithPath: path)
            let filePath = url.appendingPathComponent(audioName!)?.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath!) {
                playLocal()
            } else {
                playOnline()
            }
            player.seek(to: kCMTimeZero)
            player.play()
            
            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
            isPlay = true
            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
            timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
            timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
            NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            isEnd = true
            
            DispatchQueue.main.async {
                self.playerMini?.playerMiniNameSongLabel.text = self.arrName[self.playingIndexPath.row]
                let itemArrVoc = self.arrVoc[self.playingIndexPath.row]
                self.vocAndMean = self.topicModel.handleVoc(voc: itemArrVoc)
                self.playerMini?.nameSongOnTopLabel.text = self.arrName[self.playingIndexPath.row]
                self.handleLyricSong(lyris_string_url: self.arrLyrics[self.playingIndexPath.row])
//                self.playerMini?.lyricsTextView.reloadInputViews()
                self.playerMini?.vocTableView.reloadData()
                self.playerMini?.playListSongTableView.reloadData()
            }
            
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
        handleNextButton()
    }
    
    func handlePreMainPlayButton() {
        handlePreButton()
    }
    
    func handleNextButton() {
        if playingIndexPath.row >= arrAudio_link.count - 2 {
            playerMini?.nextMainPlayButton.isEnabled = false
        } else {
            playerMini?.nextMainPlayButton.isEnabled = true
        }
        
        playerMini?.preMainPlayButton.isEnabled = true
        let newPlayingIndexPath = IndexPath(row: playingIndexPath.row + 1, section: 0)
        self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
        DispatchQueue.main.async {
            self.playerMini?.vocTableView.reloadData()
//            self.playerMini?.lyricsTextView.reloadInputViews()
        }
        playerMini?.playerMiniNameSongLabel.text = playerMini?.nameSongOnTopLabel.text
    }
    
    func handlePreButton() {
        if playingIndexPath.row <= 1 {
            playerMini?.preMainPlayButton.isEnabled = false
        } else {
            playerMini?.preMainPlayButton.isEnabled = true
        }
        
        playerMini?.nextMainPlayButton.isEnabled = true
        let newPlayingIndexPath = IndexPath(row: playingIndexPath.row - 1, section: 0)
        self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
        DispatchQueue.main.async {
            self.playerMini?.vocTableView.reloadData()
//            self.playerMini?.lyricsTextView.reloadInputViews()
        }
        playerMini?.playerMiniNameSongLabel.text = playerMini?.nameSongOnTopLabel.text
    }
    
    func handleNextMiniPlayButton() {
        handleNextButton()
        
    }
    
    func handlePreMiniPlayButton() {
        handlePreButton()
    }
    
    func getData() {
        arrName.removeAll()
        arrAudio_link.removeAll()
        arrImage_link.removeAll()
        arrDesc.removeAll()
        arrLyrics.removeAll()
        arrVoc.removeAll()
        vocAndMean.removeAll()
        
        str = "{\"jsonrpc\":\"2.0\",\"method\":\"bbc_english.category.getSongFull\",\"id\":\"gtl_3\",\"params\":{\"id\": \(id),\"year\":\(year)},\"apiVersion\": \"v1\"}"
        
        if let arrNameObject = arrNameCache.object(forKey: str as AnyObject), let arrImage_linkObject = arrImage_linkCache.object(forKey: str as AnyObject), let arrDescObject = arrDescCache.object(forKey: str as AnyObject) {
            
            stopAnimating()
            if let arrNameObject = arrNameObject as? [String] {
                arrName = arrNameObject
            }
            if let arrImage_linkObject = arrImage_linkObject as? [String] {
                arrImage_link = arrImage_linkObject
            }
            if let arrDescObject = arrDescObject as? [String] {
                arrDesc = arrDescObject
            }
            
        } else {
            handleDataFromAPIOnMenu(str: str)
        }
        
        if let arrAudio_linkObject = arrAudio_linkCache.object(forKey: str as AnyObject), let arrLyricsObject = arrLyricsCache.object(forKey: str as AnyObject), let arrVocObject = arrVocCache.object(forKey: str as AnyObject) {
            if let arrAudio_linkObject = arrAudio_linkObject as? [String] {
                arrAudio_link = arrAudio_linkObject
            }
            if let arrLyricsObject = arrLyricsObject as? [String] {
                arrLyrics = arrLyricsObject
            }
            if let arrVocObject = arrVocObject as? [String] {
                arrVoc = arrVocObject
            }
            
        } else {
            handleDataFromAPIOnPlayer()
        }
        
    }
    
    func handleDataFromAPIOnMenu(str: String) {
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
                                    self.topicModel.image_link = index["image_link"] as! String
                                    self.topicModel.desc = index["desc"] as! String
                                    
                                    self.arrName.append(self.topicModel.name)
                                    self.arrImage_link.append(self.topicModel.image_link)
                                    self.arrDesc.append(self.topicModel.desc)
                                }
                                
                                arrNameCache.setObject(self.arrName as AnyObject, forKey: str as AnyObject)
                                arrImage_linkCache.setObject(self.arrImage_link as AnyObject, forKey: str as AnyObject)
                                arrDescCache.setObject(self.arrDesc as AnyObject, forKey: str as AnyObject)
                                
                                DispatchQueue.main.async {
                                    self.homeTableView.reloadData()
                                    self.playerMini?.vocTableView.reloadData()
                                    self.playerMini?.playListSongTableView.reloadData()
                                    self.stopAnimating()
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            
        }
        
        task.resume()
    }
    
    func handleDataFromAPIOnPlayer() {
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
                                    self.topicModel.audio_link = index["audio_link"] as! String
                                    
                                    if let index = index["html_link"] as? String, !index.isEmpty {
                                        self.topicModel.html_link = index
                                    }
                                    if let index = index["voc"] as? String {
                                        self.topicModel.voc = index
                                    }
                                    
                                    self.arrAudio_link.append(self.topicModel.audio_link)
                                    self.arrLyrics.append(self.topicModel.html_link)
                                    self.arrVoc.append(self.topicModel.voc)
                                }
                                
                                arrAudio_linkCache.setObject(self.arrAudio_link as AnyObject, forKey: self.str as AnyObject)
                                arrLyricsCache.setObject(self.arrLyrics as AnyObject, forKey: self.str as AnyObject)
                                arrVocCache.setObject(self.arrVoc as AnyObject, forKey: self.str as AnyObject)
                                
                                DispatchQueue.main.async {
                                    self.homeTableView.reloadData()
                                    self.playerMini?.vocTableView.reloadData()
                                    self.playerMini?.playListSongTableView.reloadData()
                                    self.stopAnimating()
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            
        }
        
        task.resume()
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
            self.playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
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
        let tag = sender.tag
        let keyDict: String = "\(tag)\(id)\(year)"
        
        let imgOn = UIImage(named: "Home-button-like-on.png")
        let imgOff = UIImage(named: "Home-button-like-off.png")
        if sender.currentBackgroundImage == imgOn {
            dictNameFavorite.removeValue(forKey: keyDict)
            dictImage_linkFavorite.removeValue(forKey: keyDict)
            dictDescFavorite.removeValue(forKey: keyDict)
            
            dictYear.removeValue(forKey: tag)
            dictID.removeValue(forKey: tag)
            dictHomeLikeButton.removeValue(forKey: tag)
            sender.setBackgroundImage(imgOff, for: .normal)
        } else if sender.currentBackgroundImage == imgOff {
            dictNameFavorite[keyDict] = arrName[tag]
            dictImage_linkFavorite[keyDict] = arrImage_link[tag]
            dictDescFavorite[keyDict] = arrDesc[tag]
            
            dictYear[tag] = year
            dictID[tag] = id
            dictHomeLikeButton[tag] = tag
            sender.setBackgroundImage(imgOn, for: .normal)
        }
    }
    
    @IBAction func handleShowMenuButton(_ sender: UIButton) {
        self.menu?.openMenu()
        UIView.animate(withDuration: 0.3) {
            self.opacityView?.alpha = 0.6
        }
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
                
                
                cell.homeLikeButton.tag = indexPath.row
                cell.homeLikeButton.addTarget(self, action: #selector(self.handlePressHomeLikeButton), for: .touchUpInside)
                
            }
            
            for (key, _) in self.dictHomeLikeButton {
                
                    if cell.homeLikeButton.tag == key && year == dictYear[key] && id == dictID[key] {
                        DispatchQueue.main.async {
                            cell.homeLikeButton.setBackgroundImage(UIImage(named: "Home-button-like-on.png"), for: .normal)
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
                arrNameFavorite.removeAll()
                arrImage_linkFavorite.removeAll()
                arrDescFavorite.removeAll()
                arrYear.removeAll()
                
                for ( _, value) in dictNameFavorite {
                    arrNameFavorite.append(value)
                }
                for ( _, value) in dictImage_linkFavorite {
                    arrImage_linkFavorite.append(value)
                }
                for ( _, value) in dictDescFavorite {
                    arrDescFavorite.append(value)
                }
                
                arrName = arrNameFavorite
                arrImage_link = arrImage_linkFavorite
                arrDesc = arrDescFavorite
                id = -1
                year = 0
                hideMenu()
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
            if indexPath != indexPathSelected {
                startAnimating()
                cell.setIndicatorViewColor(color: UIColor.red)
                cell.setYearLabelColor(color: UIColor.black)
                year = arrYear[indexPath.row]
                self.getData()
                indexPathSelected = indexPath
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                    collectionView.reloadData()
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? YearCollectionViewCell {
            cell.setIndicatorViewColor(color: UIColor.white)
            cell.setYearLabelColor(color: UIColor.lightGray)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: collectionView.frame.height)
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
