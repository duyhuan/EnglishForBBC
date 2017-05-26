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
    @IBOutlet weak var homeTableViewSpaceBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var yearCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var player = AVPlayer()
    var audio_linkString = ""
    var str = ""
    
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
    
    let heightSectionHeaderMenu: CGFloat = 30.0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var spiningActivity = MBProgressHUD()
    var refresher: UIRefreshControl?
    
    var dictFavorite: NSMutableDictionary?
    var listFavorite: [PostModel] = []
    let modelTopic = ModelTopic()
    var listTopic: [TopicModel] = []
    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as Array
    var docPath = ""
    var plistPath = ""
    
    var currentListData : [PostModel]?
    var cachedListData: [String: [PostModel]] = [:]
    var favoriteListData: [PostModel]?
    
    let audioSession = AVAudioSession.sharedInstance()
    
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
        menu?.delegate = self
        playerMini = PlayerMini.instanceFromNib()
        settingView = SettingView.instanceFromNib()
        
        playerMini?.timeSlider.setThumbImage(UIImage(named: "PlayerMain-icon-lineplaying.png"), for: UIControlState.normal)
        playerMini?.timeSlider.setThumbImage(UIImage(named: "PlayerMain-icon-lineplaying.png"), for: UIControlState.highlighted)
        
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
//            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        } catch {
//            print(error)
//        }
        
        playerMini?.playMiniPlayButton.addTarget(self, action: #selector(handlePlayMiniPlayButton), for: .touchUpInside)
        
        playerMini?.playMainPlayButton.addTarget(self, action: #selector(handlePlayMainPlayButton), for: .touchUpInside)
        
        playerMini?.repeatButton.addTarget(self, action: #selector(handleRepeatButton), for: .touchUpInside)
        
        playerMini?.exchangeButton.addTarget(self, action: #selector(handleExchangeButton), for: .touchUpInside)
        
        playerMini?.timeSlider.addTarget(self, action: #selector(handleTimeSlider), for: .valueChanged)
        
        playerMini?.nextMainPlayButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        playerMini?.preMainPlayButton.addTarget(self, action: #selector(handlePreButton), for: .touchUpInside)
        playerMini?.nextMiniPlayButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        playerMini?.preMiniPlayButton.addTarget(self, action: #selector(handlePreButton), for: .touchUpInside)
        playerMini?.playerMiniLikeButton.addTarget(self, action: #selector(handlePlayerMiniLikeButton), for: .touchUpInside)
        playerMini?.playerMiniDownloadButton.addTarget(self, action: #selector(handleDownloadButton), for: .touchUpInside)
        
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
        homeTableView.tableFooterView = UIView()
        
        docPath = directories[0] as String
        plistPath = docPath + "/data.plist"
        dictFavorite = NSMutableDictionary(contentsOfFile: plistPath)
        
        if dictFavorite == nil {
            dictFavorite = NSMutableDictionary()
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
        self.playerMini?.setFrame(view: self.view)
        setupActivityIndicator()
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerMini?.showInView(view: self.view)
        self.playerMini?.setFrame(view: self.view)
        self.opacityView?.showInView(view: self.view)
        self.menu?.showInView(view: self.view)
        self.menu?.setFrame(view: self.view)
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
        guard let messageURL = URL(string: lyris_string_url) else {return}
        let dataTask = URLSession.shared.dataTask(with: messageURL) { (data, urlResponse, error) in
            
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
                        self.playerMini?.setFontLyricTextView()
                }
                
            }
            
        }
        dataTask.resume()
    }
    
    func handlePlayMiniPlayButton() {
        handlePlayMiniPlay()
    }
    
    func handlePlayMiniPlay() {
        if playerMini?.playMiniPlayButton.currentImage == UIImage(named: "PlayerMini-icon-pause.png") {
            player_mini_playing()
            player_main_playing()
            
            handlePlay()
        } else {
            player_mini_pause()
            player_main_pause()
            
            handlePause()
        }
    }
    
    func handlePlayMainPlayButton() {
        handlePlayMainPlay()
    }
    
    func handlePlayMainPlay() {
        if playerMini?.playMainPlayButton.currentImage == UIImage(named: "PlayerMain-icon-Pause.png") {
            player_main_playing()
            player_mini_playing()
            
            handlePlay()
        } else {
            player_main_pause()
            player_mini_pause()
            
            handlePause()
        }
    }
    
    func handlePlay() {
        
        guard let audioName = URL(string: audio_linkString)?.lastPathComponent else {return}
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(audioName)?.path
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
    
    func handlePause() {
        player.seek(to: kCMTimeZero)
        player.pause()
        timerUpdateCurrentTime.invalidate()
        timerShowDuration.invalidate()
    }

    func handleRepeatButton() {
        if playerMini?.repeatButton.currentImage == UIImage(named: "PlayerMain-icon-repeat-off.png") {
            player_main_repeat_on()
        } else {
            player_main_repeat_off()
        }
    }
    
    func handleExchangeButton() {
        if playerMini?.exchangeButton.currentImage == UIImage(named: "PlayerMain-icon-Exchange-off.png") {
            player_main_exchange_on()
        } else {
            player_main_exchange_off()
        }
    }

    func handleTimeSlider() {
        player.seek(to: CMTime(seconds: Double((playerMini?.timeSlider.value)! * Float((player.currentItem?.duration.seconds)!)) , preferredTimescale: 1))
        
        let timeCurrent = (player.currentItem?.currentTime().seconds)!
        let currentSeconds = Int(timeCurrent) % 60
        let currentMinutes = Int(timeCurrent / 60)
        playerMini?.currentTimeLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
    }
    
    func handleNextButton() {
        if (currentListData?.count)! > 1 && playingIndexPath.row <= (currentListData?.count)! - 2 {
            let newPlayingIndexPath = IndexPath(row: playingIndexPath.row + 1, section: 0)
            self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
            }
            playerMini?.playerMiniNameSongLabel.text = playerMini?.nameSongOnTopLabel.text
        }
    }
    
    func handlePreButton() {
        if (currentListData?.count)! > 1 && playingIndexPath.row >= 1 {
            let newPlayingIndexPath = IndexPath(row: playingIndexPath.row - 1, section: 0)
            self.tableView((playerMini?.playListSongTableView)!, didSelectRowAt: newPlayingIndexPath)
            DispatchQueue.main.async {
                self.playerMini?.vocTableView.reloadData()
            }
            playerMini?.playerMiniNameSongLabel.text = playerMini?.nameSongOnTopLabel.text
        }
    }
    
    func getData() {
        vocAndMean.removeAll()
        
        str = "{\"jsonrpc\":\"2.0\",\"method\":\"bbc_english.category.getSongFull\",\"id\":\"gtl_3\",\"params\":{\"id\": \(id),\"year\":\(year)},\"apiVersion\": \"v1\"}"
        
        if let listData = self.cachedListData[str]{
            self.currentListData = listData
            
            self.homeTableView.reloadData()
            self.playerMini?.vocTableView.reloadData()
            self.playerMini?.playListSongTableView.reloadData()
            self.stopAnimating()
        } else {
            loadDataOnMenu(params: str)
        }
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
    
    func handlePlaying() {
        player_mini_playing()
        player_main_playing()
        
        
        do {
//            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print(error)
        }
        
        guard let audioName = URL(string: audio_linkString)?.lastPathComponent else {return}
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(audioName)?.path
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
        if playerMini?.repeatButton.currentImage == UIImage(named: "PlayerMain-icon-repeat-on.png") {
            player.seek(to: kCMTimeZero)
            player.play()
        } else {
            if playerMini?.exchangeButton.currentImage == UIImage(named: "PlayerMain-icon-Exchange-off.png") {
                player_mini_pause()
                player_main_pause()
                
                timerUpdateCurrentTime.invalidate()
                timerShowDuration.invalidate()
                player.seek(to: kCMTimeZero)
                player.pause()
            } else {
                playingIndexPath.row += 1
                audio_linkString = (currentListData?[playingIndexPath.row].audio_link)!
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
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                
                DispatchQueue.main.async {
                    self.playerMini?.playerMiniNameSongLabel.text = self.currentListData?[self.playingIndexPath.row].name
                    let itemArrVoc = self.currentListData?[self.playingIndexPath.row].voc
                    self.vocAndMean = self.topicModel.handleVoc(voc: itemArrVoc!)
                    self.playerMini?.nameSongOnTopLabel.text = self.currentListData?[self.playingIndexPath.row].name
                    self.handleLyricSong(lyris_string_url: (self.currentListData?[self.playingIndexPath.row].html_link)!)
                    self.playerMini?.vocTableView.reloadData()
                    self.playerMini?.playListSongTableView.reloadData()
                }
            }
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
    
    func handleDownloadButton(_ sender: UIButton) {
        
        if sender.currentImage == UIImage(named: "PlayerMain-icon-down-off.png") {
            sender.setImage(UIImage(named: "PlayerMain-icon-down-on.png"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "PlayerMain-icon-down-off.png"), for: .normal)
        }
        
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
//                if let bundle = Bundle.main.path(forResource: "data", ofType: "plist") {
//                    try fileManager.copyItem(atPath: bundle, toPath: plistPath)
//                }
//            } catch {
//                print("Copy failure")
//            }
//        }
        
        let tag = sender.tag
        
        modelTopic.id = id
        modelTopic.year = year
        modelTopic.name = currentListData?[tag].name
        modelTopic.desc = currentListData?[tag].desc
        modelTopic.image_link = currentListData?[tag].image_link
        modelTopic.voc = currentListData?[tag].voc
        modelTopic.html_link = currentListData?[tag].html_link
        modelTopic.audio_link = currentListData?[tag].audio_link
        
        let dictTopic: [String: Any] = ["id": modelTopic.id!, "year": modelTopic.year!, "name": modelTopic.name!, "desc": modelTopic.desc!, "image_link": modelTopic.image_link!, "voc": modelTopic.voc!, "html_link": modelTopic.html_link!, "audio_link": modelTopic.audio_link!]
        
        if sender.currentImage == UIImage(named: "Home-button-like-off.png") {
            sender.setImage(UIImage(named: "Home-button-like-on.png"), for: .normal)
            dictFavorite?[modelTopic.name!] = dictTopic
        } else {
            sender.setImage(UIImage(named: "Home-button-like-off.png"), for: .normal)
            dictFavorite?.removeObject(forKey: modelTopic.name!)
        }
        dictFavorite?.write(toFile: plistPath, atomically: true)
        favoriteListData = [PostModel]()
//        if id == -1 && year == 0 {
            for (_ , value) in dictFavorite! {
                let favorite = PostModel()
                let valueItem = value as! [String: Any]
                favorite.name = valueItem["name"] as! String
                favorite.desc = valueItem["desc"] as! String
                favorite.image_link = valueItem["image_link"] as! String
                favorite.audio_link = valueItem["audio_link"] as! String
                if let valueItemVoc = valueItem["voc"] as? String {
                    favorite.voc = valueItemVoc
                }
                if let valueItemHtml_link = valueItem["html_link"] as? String {
                    favorite.html_link = valueItemHtml_link
                }
                favoriteListData?.append(favorite)
            }
//            currentListData = favoriteListData
        
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
            }
//        }
    }
    
    func handlePlayerMiniLikeButton(sender: UIButton) {
        modelTopic.id = id
        modelTopic.year = year
        modelTopic.name = currentListData?[playingIndexPath.row].name
        modelTopic.desc = currentListData?[playingIndexPath.row].desc
        modelTopic.image_link = currentListData?[playingIndexPath.row].image_link
        modelTopic.voc = currentListData?[playingIndexPath.row].voc
        modelTopic.html_link = currentListData?[playingIndexPath.row].html_link
        modelTopic.audio_link = currentListData?[playingIndexPath.row].audio_link
        
        let dictTopic: [String: Any] = ["id": modelTopic.id!, "year": modelTopic.year!, "name": modelTopic.name!, "desc": modelTopic.desc!, "image_link": modelTopic.image_link!, "voc": modelTopic.voc!, "html_link": modelTopic.html_link!, "audio_link": modelTopic.audio_link!]
        
        if sender.currentImage == UIImage(named: "PlayerMain-icon-like-off.png") {
            player_main_like_on()
            sender.setImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
            dictFavorite?[modelTopic.name!] = dictTopic
        } else {
            player_main_like_off()
            dictFavorite?.removeObject(forKey: modelTopic.name!)
        }
        homeTableView.reloadData()
        dictFavorite?.write(toFile: plistPath, atomically: true)
        
        if id == -1 && year == 0 {
            
            var favoriteListData = [PostModel]()
            for (_ , value) in dictFavorite! {
                let favorite = PostModel()
                let valueItem = value as! [String: Any]
                favorite.name = valueItem["name"] as! String
                favorite.desc = valueItem["desc"] as! String
                favorite.image_link = valueItem["img"] as! String
                favoriteListData.append(favorite)
            }
            currentListData = favoriteListData
            
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
        playerMini?.playMiniPlayButton.setImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
    }
    
    func player_mini_playing() {
        playerMini?.playMiniPlayButton.setImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
    }
    
    func player_main_pause() {
        playerMini?.playMainPlayButton.setImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
    }
    
    func player_main_playing() {
        playerMini?.playMainPlayButton.setImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
    }
    
    func player_main_down_off() {
        playerMini?.playerMiniDownloadButton.setImage(UIImage(named: "PlayerMain-icon-down-off.png"), for: .normal)
    }
    
    func player_main_down_on() {
        playerMini?.playerMiniDownloadButton.setImage(UIImage(named: "PlayerMain-icon-down-on.png"), for: .normal)
    }
    
    func player_main_exchange_off() {
        playerMini?.exchangeButton.setImage(UIImage(named: "PlayerMain-icon-Exchange-off.png"), for: .normal)
    }
    
    func player_main_exchange_on() {
        playerMini?.exchangeButton.setImage(UIImage(named: "PlayerMain-icon-Exchange-on.png"), for: .normal)
    }
    
    func player_main_like_off(){
        playerMini?.playerMiniLikeButton.setImage(UIImage(named: "PlayerMain-icon-like-off.png"), for: .normal)
    }
    
    func player_main_like_on() {
        playerMini?.playerMiniLikeButton.setImage(UIImage(named: "PlayerMain-icon-like-on.png"), for: .normal)
    }
    
    func player_main_repeat_off() {
        playerMini?.repeatButton.setImage(UIImage(named: "PlayerMain-icon-repeat-off.png"), for: .normal)
    }
    
    func player_main_repeat_on() {
        playerMini?.repeatButton.setImage(UIImage(named: "PlayerMain-icon-repeat-on.png"), for: .normal)
    }
    
    //MARK: - API
    func loadDataOnMenu(params: String) {
        TopicService.loadAllTopic(params: params) { (data, error) in
            if let listData = data {
                //Thanh cong
                self.currentListData = listData
                self.cachedListData[params] = listData
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                    self.playerMini?.vocTableView.reloadData()
                    self.playerMini?.playListSongTableView.reloadData()
                    self.stopAnimating()
                }
            } else if error != nil {
                //Co loi
                print("Error when loading list post : err")
            }
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

extension ViewController: ProtocolDelegate {
    func handleAlphaOpacityView(alpha: CGFloat) {
        opacityView?.alpha = alpha
    }
}
