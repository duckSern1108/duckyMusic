//
//  SpotifyAuth.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import Foundation
import Alamofire
import ObjectMapper
import Security

class AuthRespons:Mappable {
    var token = ""
    var type = ""
    var expiresIn:Double = 0
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        token <- map["access_token"]
        type <- map["token_type"]
        expiresIn <- map["expires_in"]
    }
    
}

class SpotifyAuth {
    var token = ""
    var expirationTime: Double?
    var tokenType = ""
    var authorToken:String {
        tokenType + " " + token
    }
    
    var getTokenTimer: Timer?
    
    let baseURL = "https://accounts.spotify.com/api/token"
    
    let spotifyToken:String = {
        let CLIENT_ID = "82db669bedd846bfa068d9273c185dee"
        let CLIENT_SECRET = "6b997b5bcdd4467ba942e8a39846ebeb"
        let strToken = CLIENT_ID + ":"+CLIENT_SECRET
        return Data(strToken.utf8).base64EncodedString()
    }()
    
    let authParam = AuthParam()
    
    static let shared = SpotifyAuth()
    
    
    private init() {
        getTokenFromKeychain()
        tokenType = UserDefaults.standard.string(forKey: "tokenType") ?? ""
        expirationTime = UserDefaults.standard.double(forKey: "tokenExpirationIn")
        if (expirationTime == nil || expirationTime! < Date().timeIntervalSince1970) {            
            getToken {
                
            }
        }
    }
    
    deinit {
        getTokenTimer?.invalidate()
    }
    
    func saveTokenToKeychain() {
        UserDefaults.standard.set(expirationTime, forKey: "tokenExpirationIn")
        UserDefaults.standard.set(tokenType, forKey: "tokenType")
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
    
    func getTokenFromKeychain() {
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
            return
        }
        let dic = result as! NSDictionary
        let dataToken = dic[kSecValueData] as! Data
        let token = String(data: dataToken, encoding: .utf8)!
        self.token = token
    }
    
    func getToken(completion: @escaping () -> Void) {
        let currentDate = Date().timeIntervalSince1970
        if let expirationTime = expirationTime {
            if (currentDate < expirationTime) {
                completion()
                return
            }
        }
        AF.request(baseURL,
                   method: .post,
                   parameters: authParam,
                   headers: [
                    .authorization("Basic " + spotifyToken)
                   ])
        .responseString { result in
            switch result.result {
            case .success(let data):
                let response = Mapper<AuthRespons>().map(JSONString: data)!
                let dateHasToken = Date().timeIntervalSince1970
                self.token = response.token
                self.tokenType = response.type
                self.expirationTime = dateHasToken + response.expiresIn
                self.saveTokenToKeychain()
                self.getTokenTimer = Timer.scheduledTimer(withTimeInterval: response.expiresIn, repeats: false) { [weak self] _ in
                    self?.getToken {
                        
                    }
                }
                completion()
            case .failure(let error):
                print("error :: ",error)
                
            }
        }
        
    }
}
struct AuthParam: Encodable {
    let grant_type = "client_credentials"
}
