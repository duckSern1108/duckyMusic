//
//  KeyChainService.swift
//  DuckyMusic
//
//  Created by ghtk on 22/07/2022.
//

import Foundation

class KeyChainService {
    static func saveToken(token: String) {
        var query = [
            kSecValueData: token.data(using: .utf8)!,
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: "spotify",
        ] as CFDictionary
        let status = SecItemAdd(query, nil)
        if (status != 0) {
            query = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrServer: "spotify",
            ] as CFDictionary
            let updateFields = [
                kSecValueData: token.data(using: .utf8)!
            ] as CFDictionary
            SecItemUpdate(query, updateFields)
        }
    }
    
    static func getToken() -> String {
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: "spotify",
            kSecMatchLimit: 1,
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ] as CFDictionary
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        if (result == nil) {
            return ""
        }
        let dic = result as! NSDictionary
        let dataToken = dic[kSecValueData] as! Data
        let token = String(data: dataToken, encoding: .utf8)!
        return token
    }
}
