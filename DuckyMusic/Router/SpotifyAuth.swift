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
        token = KeyChainService.getToken()
        let tokenInfo = UserDefaultService.getTokenInfo()
        tokenType = tokenInfo.tokenType
        expirationTime = tokenInfo.expirationTime
        if (expirationTime == nil || expirationTime! < Date().timeIntervalSince1970) {            
            getToken {
                
            }
        }
    }
    
    deinit {
        getTokenTimer?.invalidate()
    }
    
    func saveToken() {
        UserDefaultService.saveTokenInfo(expirationTime: expirationTime, tokenType: tokenType)
        KeyChainService.saveToken(token: token)
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
                self.saveToken()
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
