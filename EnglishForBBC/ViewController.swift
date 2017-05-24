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
    
    var dictFavorite: NSMutableDictionary?
    let modelTopic = ModelTopic()
    var listTopic: [TopicModel] = []
    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as Array
    var docPath = ""
    var plistPath = ""
    
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
        playerMini?.playerMiniLikeButton.addTarget(self, action: #selector(handlePlayerMiniLikeButton), for: .touchUpInside)
        
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
        
        
        docPath = directories[0] as String
        plistPath = docPath.appending("data.plist")
        dictFavorite = NSMutableDictionary(contentsOfFile: plistPath)
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
        if playerMini?.repeatButton.currentBackgroundImage == UIImage(named: "PlayerMain-icon-repeat-off.png") {
            player_main_repeat_on()
        } else {
            player_main_repeat_off()
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleExchangeButton() {
        if playerMini?.exchangeButton.currentBackgroundImage == UIImage(named: "PlayerMain-icon-Exchange-off.png") {
            player_main_exchange_on()
        } else {
            player_main_exchange_off()
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleRepeatExchange() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func handleRepeatExchangeMusic() {
//        if !isExchange {
//            if !isRepeat {
//                player.seek(to: kCMTimeZero)
//                player.pause()
//            } else {
//                player.seek(to: kCMTimeZero)
//                player.play()
//            }
//        } else {
//            if isEnd == true {
//                playingIndexPath.row += 1
//            }
//            audio_linkString = arrAudio_link[playingIndexPath.row]
//            let audioName = URL(string: audio_linkString)?.lastPathComponent
//            
//            let url = NSURL(fileURLWithPath: path)
//            let filePath = url.appendingPathComponent(audioName!)?.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath!) {
//                playLocal()
//            } else {
//                playOnline()
//            }
//            player.seek(to: kCMTimeZero)
//            player.play()
//            
//            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
//            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
//            timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
//            timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
//            NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//            isEnd = true
//            
//            DispatchQueue.main.async {
//                self.playerMini?.playerMiniNameSongLabel.text = self.arrName[self.playingIndexPath.row]
//                let itemArrVoc = self.arrVoc[self.playingIndexPath.row]
//                self.vocAndMean = self.topicModel.handleVoc(voc: itemArrVoc)
//                self.playerMini?.nameSongOnTopLabel.text = self.arrName[self.playingIndexPath.row]
//                self.handleLyricSong(lyris_string_url: self.arrLyrics[self.playingIndexPath.row])
////                self.playerMini?.lyricsTextView.reloadInputViews()
//                self.playerMini?.vocTableView.reloadData()
//                self.playerMini?.playListSongTableView.reloadData()
//            }
//            
//        }
        
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
        print(playingIndexPath.row)
        print(arrName.count)
        if playingIndexPath.row >= arrName.count - 2 {
            playerMini?.nextMainPlayButton.isEnabled = false
        } else {
            playerMini?.nextMainPlayButton.isEnabled = true
        }
        
        playerMini?.preMainPlayButton.isEnabled = true
        let newPlayingIndexPath = IndexPath(row: playingIndexPath.row + 1, section: 0)
        self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
        DispatchQueue.main.async {
            self.playerMini?.vocTableView.reloadData()
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
        self.listTopic.removeAll()
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
                                    let topic = TopicModel()
                                    topic.name = index["name"] as! String
                                    topic.image_link = index["image_link"] as! String
                                    topic.desc = index["desc"] as! String
                                    self.topicModel.name = index["name"] as! String
                                    self.topicModel.image_link = index["image_link"] as! String
                                    self.topicModel.desc = index["desc"] as! String
                                    self.listTopic.append(topic)
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
//        handleRepeatExchange()
        if playerMini?.playMainPlayButton.currentBackgroundImage == UIImage(named: "PlayerMain-icon-Pause.png") {
            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
            
//            let audioName = URL(string: audio_linkString)?.lastPathComponent
//            let url = NSURL(fileURLWithPath: path)
//            let filePath = url.appendingPathComponent(audioName!)?.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath!) {
//                playLocal()
//            } else {
//                playOnline()
//            }
//            player.play()
//            
//            timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
//            timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
            
            
            //            handlePlaying()
            
            NotificationCenter.default.addObserver(self, selector: #selector(hande_play_button), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        } else  {
            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
            
            timerUpdateCurrentTime.invalidate()
            player.seek(to: kCMTimeZero)
            player.pause()
        }
    }
    
    func hande_play_button() {
//        if !isExchange {
//            if !isRepeat {
//                player.seek(to: kCMTimeZero)
//                player.pause()
//            } else {
//                player.seek(to: kCMTimeZero)
//                player.play()
//            }
//        }
//        else {
//            if isEnd == true {
//                playingIndexPath.row += 1
//            }
//            audio_linkString = arrAudio_link[playingIndexPath.row]
//            let audioName = URL(string: audio_linkString)?.lastPathComponent
//            
//            let url = NSURL(fileURLWithPath: path)
//            let filePath = url.appendingPathComponent(audioName!)?.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath!) {
//                playLocal()
//            } else {
//                playOnline()
//            }
//            player.seek(to: kCMTimeZero)
//            player.play()
//            
//            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
//            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
//            timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
//            timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
//            NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//            isEnd = true
//            
//            DispatchQueue.main.async {
//                self.playerMini?.playerMiniNameSongLabel.text = self.arrName[self.playingIndexPath.row]
//                let itemArrVoc = self.arrVoc[self.playingIndexPath.row]
//                self.vocAndMean = self.topicModel.handleVoc(voc: itemArrVoc)
//                self.playerMini?.nameSongOnTopLabel.text = self.arrName[self.playingIndexPath.row]
//                self.handleLyricSong(lyris_string_url: self.arrLyrics[self.playingIndexPath.row])
//                //                self.playerMini?.lyricsTextView.reloadInputViews()
//                self.playerMini?.vocTableView.reloadData()
//                self.playerMini?.playListSongTableView.reloadData()
//            }
//            
//        }
    }
    
    func handlePlaying() {
        player_mini_playing()
        player_main_playing()
        
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

        timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
        timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playerDidFinishPlaying() {
        if playerMini?.exchangeButton.currentBackgroundImage == UIImage(named: "PlayerMain-icon-Exchange-off.png") {
            if playerMini?.repeatButton.currentBackgroundImage == UIImage(named: "PlayerMain-icon-repeat-off.png") {
                player_mini_pause()
                player_main_pause()
                
                player.seek(to: kCMTimeZero)
                player.pause()
            } else {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        } else {
//            if isEnd == true {
                playingIndexPath.row += 1
//            }
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
            
//            playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
//            playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
            timerUpdateCurrentTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
            timerShowDuration = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showDuration), userInfo: nil, repeats: true)
            NotificationCenter.default.addObserver(self, selector: #selector(handleRepeatExchangeMusic), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//            isEnd = true
            
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
        
//        if isRepeat {
//            DispatchQueue.main.async {
//                self.player.seek(to: kCMTimeZero)
//                self.player.play()
//            }
//        } else {
//            self.playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
//            self.playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
//            player.seek(to: kCMTimeZero)
//            player.pause()
//            isPlay = false
//        }
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
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: plistPath) {
//            do {
//                try fileManager.copyItem(atPath: path!, toPath: plistPath)
//            } catch {
//                print("Copy failure")
//            }
//        }
        
        let tag = sender.tag
        modelTopic.id = id
        modelTopic.year = year
        modelTopic.name = arrName[tag]
        modelTopic.desc = arrDesc[tag]
        modelTopic.img = arrImage_link[tag]
        
        let dictTopic: [String: Any] = ["id": modelTopic.id!, "year": modelTopic.year!, "name": modelTopic.name!, "desc": modelTopic.desc!, "img": modelTopic.img!]
        
        if sender.currentBackgroundImage == UIImage(named: "Home-button-like-off.png") {
            sender.setBackgroundImage(UIImage(named: "Home-button-like-on.png"), for: .normal)
//            playerMini?.playerMiniLikeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
            dictFavorite?[modelTopic.name!] = dictTopic
        } else {
            sender.setBackgroundImage(UIImage(named: "Home-button-like-off.png"), for: .normal)
            dictFavorite?.removeObject(forKey: modelTopic.name!)
        }
        dictFavorite?.write(toFile: plistPath, atomically: true)
        
        if id == -1 && year == 0 {
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
                self.homeTableView.reloadData()
            }
        }
    }
    
    func handlePlayerMiniLikeButton(sender: UIButton) {
        
        modelTopic.id = id
        modelTopic.year = year
        modelTopic.name = arrName[playingIndexPath.row]
        modelTopic.desc = arrDesc[playingIndexPath.row]
        modelTopic.img = arrImage_link[playingIndexPath.row]
        
        let dictTopic: [String: Any] = ["id": modelTopic.id!, "year": modelTopic.year!, "name": modelTopic.name!, "desc": modelTopic.desc!, "img": modelTopic.img!]
        
        if sender.currentBackgroundImage == UIImage(named: "PlayerMain-icon-like-off.png") {
            sender.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
            dictFavorite?[modelTopic.name!] = dictTopic
        } else {
            sender.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-off.png"), for: .normal)
            dictFavorite?.removeObject(forKey: modelTopic.name!)
        }
        dictFavorite?.write(toFile: plistPath, atomically: true)
        
        if id == -1 && year == 0 {
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
                self.homeTableView.reloadData()
            }
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
    
    
    func player_mini_pause() {
        playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
    }
    
    func player_mini_playing() {
        playerMini?.playMiniPlayButton.setBackgroundImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
    }
    
    func player_main_pause() {
        playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-pause.png"), for: .normal)
    }
    
    func player_main_playing() {
        playerMini?.playMainPlayButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
    }
    
    func player_main_down_off() {
        playerMini?.player_main_down_button.setBackgroundImage(UIImage(named: "PlayerMain-icon-down-off.png"), for: .normal)
    }
    
    func player_main_down_on() {
        playerMini?.player_main_down_button.setBackgroundImage(UIImage(named: "PlayerMain-icon-down-on.png"), for: .normal)
    }
    
    func player_main_exchange_off() {
        playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-off.png"), for: .normal)
    }
    
    func player_main_exchange_on() {
        playerMini?.exchangeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-Exchange-on.png"), for: .normal)
    }
    
    func player_main_like_off(){
        playerMini?.playerMiniLikeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-off.png"), for: .normal)
    }
    
    func player_main_like_on() {
        playerMini?.playerMiniLikeButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
    }
    
    func player_main_repeat_off() {
        playerMini?.repeatButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-off.png"), for: .normal)
    }
    
    func player_main_repeat_on() {
        playerMini?.repeatButton.setBackgroundImage(UIImage(named: "PlayerMain-icon-repeat-on.png"), for: .normal)
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
