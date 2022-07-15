//
//  Track.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import Foundation
import ObjectMapper

class Track:Mappable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        artists <- map["artists"]
        previewUrl <- map["preview_url"]
        duration <- map["duration_ms"]
        images <- map["images"]
        trackNumber <- map["track_number"]
    }
    
    var id:String = ""
    var name:String = ""
    var duration:Double = 0
    var artists: [Artist] = []
    var previewUrl = ""
    var trackNumber = 0
    var artistLabel:String {
        artists.map {
            $0.name
        }.joined(separator: ", ")
    }
    
    var images: [Image] = []
    var durationText:String {
        duration.convertMsToMinuteAndSecond()
    }
    var playable:Bool {
        URL(string: previewUrl) != nil
    }
}
