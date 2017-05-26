//
//  ModelTopic.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/23/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import Foundation

class ModelTopic {
    var id: Int?
    var year: Int?
    var name: String?
    var desc: String?
    var image_link: String?
    var voc: String?
    var html_link: String?
    var audio_link: String?
    
    init() {
        
    }
    
    init(dictModelTopic: [String: Any]) {
        self.id = dictModelTopic["id"] as? Int
        self.year = dictModelTopic["year"] as? Int
        self.name = dictModelTopic["name"] as? String
        self.desc = dictModelTopic["desc"] as? String
        self.image_link = dictModelTopic["image_link"] as? String
        self.html_link = dictModelTopic["html_link"] as? String
        self.audio_link = dictModelTopic["audio_link"] as? String
    }
}
