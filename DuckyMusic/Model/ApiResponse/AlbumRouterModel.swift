//
//  AlbumRouterModel.swift
//  DuckyMusic
//
//  Created by ghtk on 22/07/2022.
//

import Foundation
import ObjectMapper

struct NewReleaseResponse: Mappable {
    var albums: [Album] = []
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        albums <- map["albums.items"]
    }
}
