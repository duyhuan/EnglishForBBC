//
//  PostModel.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/24/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class PostModel: NSObject {
    var html_link: String
    var name: String
    var voc: String
    var url: String
    var audio_link: String
    var lyric_links: String
    var image_link: String
    var pdf_link: String
    var time: String
    var html_link_backup: String
    var image_link_backup: String
    var audio_link_backup: String
    var desc: String
    
    override init() {
        self.html_link = ""
        self.name = ""
        self.voc = ""
        self.url = ""
        self.audio_link = ""
        self.lyric_links = ""
        self.image_link = ""
        self.pdf_link = ""
        self.time = ""
        self.html_link_backup = ""
        self.audio_link_backup = ""
        self.image_link_backup = ""
        self.desc = ""
    }
    
    init(html_link: String, name: String, voc: String, url: String, audio_link: String, lyric_links: String, image_link: String, pdf_link: String, time: String, html_link_backup: String, image_link_backup: String, audio_link_backup: String, desc: String) {
        self.html_link = html_link
        self.name = name
        self.voc = voc
        self.url = url
        self.audio_link = audio_link
        self.lyric_links = lyric_links
        self.image_link = image_link
        self.pdf_link = pdf_link
        self.time = time
        self.html_link_backup = html_link_backup
        self.audio_link_backup = audio_link_backup
        self.image_link_backup = image_link_backup
        self.desc = desc
    }
    
    override var description: String {
        return "\(self.name)"
    }

}
