//
//  ManagerAPI.swift
//  Player
//
//  Created by Duy Huan on 5/17/17.
//  Copyright © 2017 Duy Huan. All rights reserved.
//

import Foundation
import UIKit

enum TopicID: Int {
    case SixMinuteEnglish = 0
    case EnglishAtWork = 1
    case ExpressEnglish = 2
    case WordsInTheNews = 3
    case TheEnglishWeSpeak = 4
    case Drama = -1
    case NewReport = 6
    case LingoHack = 7
    case Pronunciation = 8
    case SixMinuteGrammar = 9
    case EnglishConversation = 10
    case SixMinuteVocabulary = 11
    case NewReview = 12
    case EnglishAtUniversity = 13
}

enum TopicName: String {
    case EnglishConversation = "English Conversation"
    case NewReport = "New Report"
    case ExpressEnglish = "Express English"
    case TheEnglishWeSpeak = "The English We Speak"
    case WordsInTheNews = "Words In The News"
    case LingoHack = "LingoHack"
    case EnglishAtUniversity = "English At University"
    case EnglishAtWork = "English At Work"
    case SixMinuteEnglish = "6 Minute English"
    case SixMinuteGrammar = "6 Minute Grammar"
    case SixMinuteVocabulary = "6 Minute Vocabulary"
    case NewReview = "New Review"
    case Drama = "Drama"
    case VocabularyFlashCards = "Vocabulary FlashCards"
    case VocabularyQuiz = "Vocabulary Quiz"
    case Pronunciation = "Pronunciation"
    case MyPlaylist = "My Playlist"
    case Downloaded = "Downloaded"
    case UpgradeProVersion = "Upgrade Pro Version"
    case FeedbackForUs = "Feedback for Us"
    case Setting = "Setting"
    case RateMe = "Rate me 5-stars"
}

enum Year {
    case abcd
    case cdef
}

let baseAPI = "https://avid-heading-737.appspot.com/_ah/api/rpc?prettyPrint=false"

class ManagerAPI {
    let yearCurrent: Int = Calendar.current.component(.year, from: Date())
    
    var id = TopicID.SixMinuteEnglish
    func getIDTopic(topicName: String) -> Int {
        switch topicName {
        case TopicName.SixMinuteEnglish.rawValue: // "6 Minute English":
            id = TopicID.SixMinuteEnglish
            break
        case TopicName.EnglishAtWork.rawValue: //"English At Work":
            id = TopicID.EnglishAtWork
            break
        case TopicName.ExpressEnglish.rawValue: //"Express English":
            id = TopicID.ExpressEnglish
            break
        case TopicName.WordsInTheNews.rawValue: //"Words In The News":
            id = TopicID.WordsInTheNews
            break
        case TopicName.TheEnglishWeSpeak.rawValue: //"The English We Speak":
            id = TopicID.TheEnglishWeSpeak
            break
        case TopicName.Drama.rawValue: //"Drama":
            id = TopicID.Drama
            break
        case TopicName.NewReport.rawValue: //"New Report":
            id = TopicID.NewReport
            break
        case TopicName.LingoHack.rawValue: //"LingoHack":
            id = TopicID.LingoHack
            break
        case TopicName.Pronunciation.rawValue: //"Pronunciation":
            id = TopicID.Pronunciation
            break
        case TopicName.SixMinuteGrammar.rawValue: //"6 Minute Grammar":
            id = TopicID.SixMinuteGrammar
            break
        case TopicName.EnglishConversation.rawValue: //"English Conversation":
            id = TopicID.EnglishConversation
            break
        case TopicName.SixMinuteVocabulary.rawValue: //"6 Minute Vocabulary":
            id = TopicID.SixMinuteVocabulary
            break
        case TopicName.NewReview.rawValue: //"New Review":
            id = TopicID.NewReview
            break
        case TopicName.EnglishAtUniversity.rawValue: //"English At University":
            id = TopicID.EnglishAtUniversity
            break
        default:
            break
        }
        return id.rawValue
    }
    
    func getArrYearOfTopic(id: Int) -> [Int] {
        var arrYearOfTopic: [Int] = [Int]()
        switch id {
        case TopicID.SixMinuteEnglish.rawValue:
            arrYearOfTopic = [2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008]
            break
        case TopicID.EnglishAtWork.rawValue:
            arrYearOfTopic = [2017, 2016, 2015]
            break
        case TopicID.ExpressEnglish.rawValue:
            arrYearOfTopic = [yearCurrent]
            break
        case TopicID.WordsInTheNews.rawValue:
            arrYearOfTopic = [2015, 2014]
            break
        case TopicID.TheEnglishWeSpeak.rawValue:
            arrYearOfTopic = [2017, 2016, 2015, 2014]
            break
        case TopicID.Drama.rawValue:
            arrYearOfTopic = []
            break
        case TopicID.NewReport.rawValue:
            arrYearOfTopic = [2016, 2015]
            break
        case TopicID.LingoHack.rawValue:
            arrYearOfTopic = [2017, 2016, 2015]
            break
        case TopicID.Pronunciation.rawValue:
            arrYearOfTopic = [yearCurrent]
            break
        case TopicID.SixMinuteGrammar.rawValue:
            arrYearOfTopic = [yearCurrent]
            break
        case TopicID.EnglishConversation.rawValue:
            arrYearOfTopic = [yearCurrent]
            break
        case TopicID.SixMinuteVocabulary.rawValue:
            arrYearOfTopic = [yearCurrent]
            break
        case TopicID.NewReview.rawValue:
            arrYearOfTopic = [2017, 2016]
            break
        case TopicID.EnglishAtUniversity.rawValue:
            arrYearOfTopic = [2017, 2016]
            break
        default:
            break
        }
        return arrYearOfTopic
    }
    
}
