//
//  SpotifyAuthModel.swift
//  DuckyMusic
//
//  Created by ghtk on 22/07/2022.
//

import Foundation
import ObjectMapper

struct AuthRespons:Mappable {
    init?(map: Map) {
        
    }
    
    var token = ""
    var type = ""
    var expiresIn:Double = 0
    
    mutating func mapping(map: Map) {
        token <- map["access_token"]
        type <- map["token_type"]
        expiresIn <- map["expires_in"]
    }
    
}

struct AuthParam: Encodable {
    let grant_type = "client_credentials"
}
