//
//  Artist.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import Foundation
import ObjectMapper

class Artist:Mappable {
    var name:String = ""
    var id:String = ""
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    required init?(map: Map) {
        
    }
}
