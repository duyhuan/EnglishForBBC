//
//  TopicService.swift
//  EnglishForBBC
//
//  Created by Duy Huan on 5/24/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import UIKit

class TopicService: NSObject {
    public static func loadAllTopic(params: String, completion:@escaping (_ data: [PostModel]?, _ error: String?) -> Void) {
        guard let url = URL(string: baseAPI) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // content-type
        let headers: Dictionary = ["Content-Type": "application/json"]
        request.allHTTPHeaderFields = headers
        
        // insert json data to the request
        let data_body = params.data(using: .utf8)
        request.httpBody = data_body
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return completion(nil, error?.localizedDescription)
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let result = responseJSON["result"] {
                    if let resultCategory = result as? [String: Any] {
                        if let resultData = resultCategory["data"] {
                            if let result = resultData as? [[String: Any]] {
                                var topics : [PostModel] = []
                                for index in result {
                                    let topic = PostModel()
                                    topic.name = index["name"] as! String
                                    topic.image_link = index["image_link"] as! String
                                    topic.desc = index["desc"] as! String
                                    topic.audio_link = index["audio_link"] as! String
                                    if let indexVoc = index["voc"] as? String {
                                        topic.voc = indexVoc
                                    }
                                    topic.html_link = index["html_link"] as! String
                                    topics.append(topic)
                                }
                                return completion(topics, nil)
                            }
                            
                        }
                    }
                    
                }
            }
            
            
        }
        
        task.resume()
    }
}
