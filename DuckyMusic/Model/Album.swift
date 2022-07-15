//
//  Album.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import Foundation
import ObjectMapper


class Image:Mappable {
    var height:Int = 0
    var width: Int = 0
    var url:String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        height <- map["height"]
        width <- map["width"]
        url <- map["url"]
    }
}

class Album:Mappable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        type <- map["album_type"]
        images <- map["images"]
        artists <- map["artists"]
        releaseDate <- map["release_date"]
        totalTracks <- map["total_tracks"]
        tracks <- map["tracks.items"]
        staticTracks <- map["tracks.items"]
    }
    var staticTracks: [Track] = []
    var id:String = ""
    var images: [Image] = []
    var name:String = ""
    var type:String = ""
    var releaseDate:String = ""
    var artists: [Artist] = []
    var totalTracks = 0
    var label = ""
    var tracks: [Track] = []
    var artistLabel:String {
        artists.map {
            $0.name
        }.joined(separator: ", ")
    }
}
