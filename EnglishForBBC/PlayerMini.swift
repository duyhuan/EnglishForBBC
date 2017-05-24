//
//  PlayerMini.swift
//  Player
//
//  Created by Duy Huan on 5/12/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var player_main_down_button: UIButton!
    
    var isExchange = true
    
    let height_mp3_mini: CGFloat = 60.0
    let lyricsTextView_leading: CGFloat = 10.0
    
    var lyricsTextView = UITextView()
    var vocTableView = UITableView()
    var playListSongTableView = UITableView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(3), height: 0.0)
        
        lyricsTextView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height))
        lyricsTextView.isEditable = false
        lyricsTextView.backgroundColor = UIColor.clear
        lyricsTextView.textColor = UIColor.white
        scrollView.addSubview(lyricsTextView)
        
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: lyricsTextView_leading))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: pagesScrollViewSize.width - lyricsTextView_leading*2))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: scrollView.frame.height))
        self.addConstraint(NSLayoutConstraint(item: lyricsTextView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 10))
        
        vocTableView.frame = CGRect(x: pagesScrollViewSize.width * CGFloat(1), y: 0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height + 10.0)
        vocTableView.register(VocTableViewCell.self, forCellReuseIdentifier: VocTableViewCell.identifier())
        vocTableView.backgroundColor = UIColor.clear
        vocTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        scrollView.addSubview(vocTableView)
        
        playListSongTableView.frame = CGRect(x: pagesScrollViewSize.width * CGFloat(2), y: 0, width: pagesScrollViewSize.width, height: pagesScrollViewSize.height + 10.0)
        playListSongTableView.backgroundColor = UIColor.clear
        playListSongTableView.register(PlayListSongTableViewCell.self, forCellReuseIdentifier: PlayListSongTableViewCell.identifier())
        playListSongTableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        scrollView.addSubview(playListSongTableView)
    }
    
    class func instanceFromNib() -> PlayerMini {
        return UINib(nibName: "PlayerMini", bundle: nil).instantiate(withOwner: nil, options: nil).first as! PlayerMini
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
    
    @IBAction func handleShowPlayerMainTapGesture(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            var f = self.frame
            f.origin.y = 0 - self.height_mp3_mini
            self.frame = f
        }
    }
    
    @IBAction func handleHidePlayerMainButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y = (self.superview?.bounds.height)! - self.height_mp3_mini
        }
    }
    
}

extension PlayerMini: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fractionalPage = scrollView.contentOffset.x / scrollView.frame.size.width
        let page = lround(Double(fractionalPage))
        pageControl.currentPage = page
    }
}
