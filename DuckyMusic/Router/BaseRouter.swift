//
//  BaseRouter.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import Foundation
import Alamofire
import ObjectMapper

typealias RequestParam = [String:String]

enum Router: URLRequestConvertible {
    case get(String,RequestParam?), post(String,RequestParam?)
    
    var baseURL: URL {
        return URL(string: "https://api.spotify.com/v1")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        }
    }
    
    func generateURLRequest(p: String) -> URLRequest {
        let url = baseURL.appendingPathComponent(p)
        var request = URLRequest(url: url)
        request.method = method
        return request
    }
    
    
    func asURLRequest() throws -> URLRequest {
        
        var request: URLRequest
        switch self {
        case let .get(path,parameters):
            request = self.generateURLRequest(p: path)
            request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
            
        case let .post(path,parameters):
            request = self.generateURLRequest(p: path)
            request = try JSONParameterEncoder().encode(parameters, into: request)
        }
        print(SpotifyAuth.shared.authorToken)
        
        request.headers = [
            .authorization(SpotifyAuth.shared.authorToken)
        ]
        
        return request
    }
}




class ApiMain {
    static let shared = ApiMain()
    
    private init() {
        
    }
    
    func request(path: String = "", method: HTTPMethod, completion:@escaping (AFDataResponse<String>) -> Void) {
        SpotifyAuth.shared.getToken {
            switch method {
            case .get:
                AF.request(Router.get(path,nil)).responseString(completionHandler: completion)
            default:
                break
            }
        }
    }
    
}


