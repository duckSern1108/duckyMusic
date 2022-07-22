//
//  UserDefaultService.swift
//  DuckyMusic
//
//  Created by ghtk on 22/07/2022.
//

import Foundation

class UserDefaultService {
    static func saveTokenInfo(expirationTime: Double?, tokenType: String) {
        UserDefaults.standard.set(expirationTime, forKey: "tokenExpirationIn")
        UserDefaults.standard.set(tokenType, forKey: "tokenType")
    }
    
    static func getTokenInfo() -> (expirationTime: Double?, tokenType: String) {
        let tokenType = UserDefaults.standard.string(forKey: "tokenType") ?? ""
        let expirationTime = UserDefaults.standard.double(forKey: "tokenExpirationIn")
        return (expirationTime: expirationTime, tokenType: tokenType)
    }
}
