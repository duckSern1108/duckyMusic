//
//  SpotifyAuth.swift
//  DuckyMusic
//
//  Created by ghtk on 11/07/2022.
//

import Foundation
import Alamofire
import ObjectMapper

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
        
    }
    
    func getToken(completion: @escaping () -> Void) {
        let currentDate = Date().timeIntervalSince1970
        if let expirationTime = expirationTime {
            if (currentDate < expirationTime) {
                completion()
                return
            }
        }
        print("auth")
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
