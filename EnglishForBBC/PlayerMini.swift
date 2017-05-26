//
//  PlayerMini.swift
//  Player
//
//  Created by Duy Huan on 5/12/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerMini: UIView {
    
    @IBOutlet weak var playerMiniAvatarImageView: UIImageView!
    @IBOutlet weak var playerMiniNameSongLabel: UILabel!
    @IBOutlet weak var playMainPlayButton: UIButton!
    @IBOutlet weak var playMiniPlayButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeTotalLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var nameSongOnTopLabel: UILabel!
    @IBOutlet weak var nextMainPlayButton: UIButton!
    @IBOutlet weak var preMainPlayButton: UIButton!
    @IBOutlet weak var nextMiniPlayButton: UIButton!
    @IBOutlet weak var preMiniPlayButton: UIButton!
    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var playerMiniLikeButton: UIButton!
    @IBOutlet weak var playerMiniDownloadButton: UIButton!
    @IBOutlet weak var topView: UIView!
    
    var playingIndexPath: IndexPath? {
        didSet {
            
        }
    }
    
    var topicModel: TopicModel?
    
    var currentListData: [PostModel]?
    var vocAndMean: [[String]] = [[String]]()
    
    var minutes: Int?
    var seconds: Int?
    var duration: Double?
    
    var isExchange = true
    
    let height_mp3_mini: CGFloat = 60.0
    let lyricsTextView_leading: CGFloat = 10.0
    var audio_linkString = ""
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    var player = AVPlayer()
    var timerUpdateCurrentTime = Timer()
    var timerShowDuration = Timer()
    
    var lyricsTextView = UITextView()
    var vocTableView = UITableView()
    var playListSongTableView = UITableView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playerMiniAvatarImageView.layer.cornerRadius = playerMiniAvatarImageView.bounds.width / 2
        playerMiniAvatarImageView.clipsToBounds = true
        
        scrollView.delegate = self
        
        vocTableView.tableFooterView = UIView()
        playListSongTableView.tableFooterView = UIView()
        
//        let pagesScrollViewSize = scrollView.bounds.size
//        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(3), height: 0.0)
        
//        playMainPlayButton.addTarget(self, action: #selector(handlePlayMainPlayButton), for: .touchUpInside)
//        playMiniPlayButton.addTarget(self, action: #selector(handlePlayMiniPlayButton), for: .touchUpInside)
    }
    
    class func instanceFromNib() -> PlayerMini {
        return UINib(nibName: "PlayerMini", bundle: nil).instantiate(withOwner: nil, options: nil).first as! PlayerMini
    }
    
    func setFontLyricTextView() {
        if let fontName = lyricsTextView.font?.fontName {
            lyricsTextView.font = UIFont(name: fontName, size: 15.0)
        }
    }
    
    func setFrame(view: UIView) {
        self.frame.size.width = view.frame.width
        self.frame.size.height = view.frame.height + height_mp3_mini
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(3), height: 0.0)
        scrollView.frame.size.width = view.bounds.size.width
        scrollView.frame.size.height = view.bounds.size.height - topView.bounds.size.height - viewPlayer.bounds.size.height

        let pagesScrollViewSize = scrollView.bounds.size
        
        lyricsTextView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height))
        lyricsTextView.isEditable = false
        lyricsTextView.showsHorizontalScrollIndicator = false
        lyricsTextView.showsVerticalScrollIndicator = false
        lyricsTextView.backgroundColor = UIColor.clear
        
        scrollView.addSubview(lyricsTextView)
        
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: lyricsTextView_leading))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: pagesScrollViewSize.width - lyricsTextView_leading*2))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: scrollView.frame.height))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 10))
        
        vocTableView.frame = CGRect(x: pagesScrollViewSize.width * CGFloat(1), y: 0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height)
        vocTableView.register(VocTableViewCell.self, forCellReuseIdentifier: VocTableViewCell.identifier())
        vocTableView.backgroundColor = UIColor.clear
        vocTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        vocTableView.showsHorizontalScrollIndicator = false
        vocTableView.showsVerticalScrollIndicator = false
        scrollView.addSubview(vocTableView)
        
        playListSongTableView.frame = CGRect(x: pagesScrollViewSize.width * CGFloat(2), y: 0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height)
        playListSongTableView.backgroundColor = UIColor.clear
        playListSongTableView.register(PlayListSongTableViewCell.self, forCellReuseIdentifier: PlayListSongTableViewCell.identifier())
        playListSongTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        playListSongTableView.showsHorizontalScrollIndicator = false
        playListSongTableView.showsVerticalScrollIndicator = false
        scrollView.addSubview(playListSongTableView)
    }
    
    func showInView(view: UIView) -> Void {
        //
        view.addSubview(self)
        
        // update fram
        var frame = self.frame
        frame.origin.y = view.frame.size.height
        self.frame = frame
    }
    
    func displayBottom(view: UIView) {
        UIView.animate(withDuration: 0.3) { 
            self.frame.origin.y = view.frame.size.height - self.height_mp3_mini
            self.frame = self.frame
        }
    }
    
    func setTimeTotalLabel(text: String) {
        timeTotalLabel.text = text
    }
    
    @IBAction func handleShowPlayerMainTapGesture(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            var f = self.frame
            f.origin.y = 0 - self.height_mp3_mini
            self.frame = f
        }
    }
    
    @IBAction func swipeToOpenSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            var f = self.frame
            f.origin.y = 0 - self.height_mp3_mini
            self.frame = f
        }
    }
    
    @IBAction func swipeToCloseSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y = (self.superview?.bounds.height)! - self.height_mp3_mini
        }
    }
    
    @IBAction func handleHidePlayerMainButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y = (self.superview?.bounds.height)! - self.height_mp3_mini
        }
    }
    
    func handlePlayMainPlayButton() {
        handlePlayMainPlay()
    }
    
    func handlePlayMainPlay() {
        if playMainPlayButton.currentImage == UIImage(named: "PlayerMain-icon-Pause.png") {
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
    
    func playerDidFinishPlaying() {
        if repeatButton.currentImage == UIImage(named: "PlayerMain-icon-repeat-on.png") {
            player.seek(to: kCMTimeZero)
            player.play()
        } else {
            if exchangeButton.currentImage == UIImage(named: "PlayerMain-icon-Exchange-off.png") {
                player_mini_pause()
                player_main_pause()
                
                timerUpdateCurrentTime.invalidate()
                timerShowDuration.invalidate()
                player.seek(to: kCMTimeZero)
                player.pause()
            } else {
                playingIndexPath?.row += 1
                audio_linkString = (currentListData?[(playingIndexPath?.row)!].audio_link)!
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
                    self.playerMiniNameSongLabel.text = self.currentListData?[(self.playingIndexPath?.row)!].name
                    let itemArrVoc = self.currentListData?[(self.playingIndexPath?.row)!].voc
                    self.vocAndMean = (self.topicModel?.handleVoc(voc: itemArrVoc!))!
                    self.nameSongOnTopLabel.text = self.currentListData?[(self.playingIndexPath?.row)!].name
                    self.handleLyricSong(lyris_string_url: (self.currentListData?[(self.playingIndexPath?.row)!].html_link)!) // self.arrLyrics[self.playingIndexPath.row]
                    self.vocTableView.reloadData()
                    self.playListSongTableView.reloadData()
                }
            }
        }
    }
    
    func handlePlayMiniPlayButton() {
        handlePlayMiniPlay()
    }
    
    func handlePlayMiniPlay() {
        if playMiniPlayButton.currentImage == UIImage(named: "PlayerMini-icon-pause.png") {
            player_mini_playing()
            //            player_main_playing()
            
            handlePlay()
        } else {
            player_mini_pause()
            //            player_main_pause()
            
            handlePause()
        }
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
                    self.lyricsTextView.attributedText = attrStr
                }
                
            }
            
        }
        dataTask.resume()
    }
    
    func player_mini_playing() {
        playMiniPlayButton.setImage(UIImage(named: "PlayerMini-icon-playing.png"), for: .normal)
    }
    func player_mini_pause() {
        playMiniPlayButton.setImage(UIImage(named: "PlayerMini-icon-pause.png"), for: .normal)
    }
    func player_main_playing() {
        playMainPlayButton.setImage(UIImage(named: "PlayerMain-icon-playing.png"), for: .normal)
    }
    func player_main_pause() {
        playMainPlayButton.setImage(UIImage(named: "PlayerMain-icon-Pause.png"), for: .normal)
    }
    
    func showDuration() {
        duration = (player.currentItem?.duration.seconds)!
        guard !((duration?.isNaN)! || (duration?.isInfinite)!) else {return}
        minutes = Int(duration!) / 60
        seconds = Int(duration!) - minutes! * 60
        timeTotalLabel.text = String(format: "%02d:%02d", minutes!, seconds!)
        if duration != nil {
            timerShowDuration.invalidate()
        }
    }
    
    func updateCurrentTime() {
        let timeCurrent = (player.currentItem?.currentTime().seconds)!
        let currentSeconds = Int(timeCurrent) % 60
        let currentMinutes = Int(timeCurrent / 60)
        duration = (player.currentItem?.duration.seconds)!
        currentTimeLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
        timeSlider.value = Float(timeCurrent / duration!)
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
    
}

extension PlayerMini: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fractionalPage = scrollView.contentOffset.x / scrollView.frame.size.width
        let page = lround(Double(fractionalPage))
        pageControl.currentPage = page
    }
}
