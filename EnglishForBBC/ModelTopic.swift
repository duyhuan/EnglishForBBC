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
    var img: String?
    
    init() {
        
    }
    
    init(dictModelTopic: [String: Any]) {
        self.id = dictModelTopic["id"] as? Int
        self.year = dictModelTopic["year"] as? Int
        self.name = dictModelTopic["name"] as? String
        self.desc = dictModelTopic["desc"] as? String
        self.img = dictModelTopic["img"] as? String
    }
}
