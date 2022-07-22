//
//  BaseRouter.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import Foundation
import Alamofire
import ObjectMapper

typealias RequestParam = [String:Int]

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
    
    func request(path: String = "", method: HTTPMethod, param: RequestParam?, completion:@escaping (AFDataResponse<String>) -> Void) {
        switch method {
        case .get:
            AF.request(Router.get(path,param)).responseString { result in
                switch result.result {
                case .success(let data):                    
                    if let unauthRes = Mapper<UnauthorResponse>().map(JSONString: data) {
                        //401 la token het han
                        //400 la ko co token type
                        if (unauthRes.errCode == 401 || unauthRes.errCode == 400) {
                            SpotifyAuth.shared.getToken { [weak self] in
                                self?.request(path: path, method: method, param: param, completion: completion)
                            }
                            return
                        }
                        
                    }
                    break
                default:
                    break
                }
                completion(result)
            }
        default:
            break
        }
        
    }
    
}


