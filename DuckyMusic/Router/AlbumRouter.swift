//
//  AlbumRouter.swift
//  DuckyMusic
//
//  Created by ghtk on 08/07/2022.
//

import Foundation
import PromiseKit
import ObjectMapper

class NewReleaseResponse: Mappable {
    var albums: [Album] = []
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        albums <- map["albums.items"]
    }
}

class AlbumRouter {
    
    static let shared = AlbumRouter()
    private init() {
        
    }
    
    func getNewRelease(offset: Int = 0,limit: Int = 20) -> Promise<[Album]> {
        return Promise {
            seal in
            ApiMain.shared.request(path: "/browse/new-releases" ,method: .get, param: ["offset": offset, "limit": limit]) { result in
                switch result.result {
                case .success(let data):
                    let response = Mapper<NewReleaseResponse>().map(JSONString: data)!
                    seal.fulfill(response.albums)
                case .failure(let error):
//                    print("error :: ",error)
                    seal.reject(error)
                }
            }
        }
    }
    
    func getAlbumInfo(id: String) -> Promise<Album> {
        return Promise { seal in
            ApiMain.shared.request(path: "/albums/\(id)",method: .get, param: nil) { result in
                switch result.result {
                case .success(let data):
                    let response = Mapper<Album>().map(JSONString: data)!
                    seal.fulfill(response)
                case .failure(let error):
//                    print("error :: ",error)
                    seal.reject(error)
                }
            }
        }
    }
}


