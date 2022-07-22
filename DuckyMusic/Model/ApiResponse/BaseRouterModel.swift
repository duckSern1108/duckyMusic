//
//  BaseRouterModel.swift
//  DuckyMusic
//
//  Created by ghtk on 22/07/2022.
//

import Foundation
import ObjectMapper

struct UnauthorResponse:Mappable {
    var errCode: Int?
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        errCode <- map["error.status"]
    }
}
