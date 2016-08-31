//
//  GiphyManager.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/29/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

typealias GifCompletion = [GiphyGif] -> Void

class GiphyManager {
    
    // Singleton
    
    static let sharedInstance = GiphyManager()
    private init() {}
    
    // Fetch Trending GIFs
    
    func fetchTrendingGifs(limit: Int = 10) -> Observable<[GiphyGif]>  {
        return Observable.create { observer in
            return self.giphyGetRequest(.Trending,
                customParams: [GiphyConfig.Params.limit: limit])
                .subscribeNext({ jsonDictionary in

                    let gifs = GiphyGif.listFromResponse(jsonDictionary)
                    NSLog("Giphy search success: \(gifs)")
                    observer.on(.Next(gifs))
                    observer.on(.Completed)
                })
        }
    }
    
    // Search for GIFs
    
    func searchForGifs(searchTerm: String, limit: Int = 10) -> Observable<[GiphyGif]> {
        return Observable.create { observer in
            return self.giphyGetRequest(.Search,
                            customParams: [GiphyConfig.Params.limit: limit, GiphyConfig.Params.search: searchTerm ])
                .subscribeNext({ jsonDictionary in
                    
                    let gifs = GiphyGif.listFromResponse(jsonDictionary)
                    NSLog("Giphy search success: \(gifs)")
                    observer.on(.Next(gifs))
                    observer.on(.Completed)
            })
        }
    }

    
    private func giphyGetRequest(endpoint: GiphyEndpoint, customParams: [String: AnyObject]? = nil) -> Observable<JSONObject> {
        return Observable.create { observer in
            let url = GiphyConfig.host + GiphyConfig.apiVersion + endpoint.rawValue
            var params: [String: AnyObject] = [GiphyConfig.Params.apiKey: GiphyConfig.apiKey]
            if let customParams = customParams {
                params += customParams
            }
            let request = Alamofire.request(.GET, url, parameters: params).responseJSON { response in
                switch response.result {
                case .Success(let data):
                    if let jsonDictionary = data as? JSONObject {
                        observer.on(.Next(jsonDictionary))
                        observer.on(.Completed)
                    }
                case .Failure(let error):
                    NSLog("Giphy API error: \(error)")
                    observer.onError(error)
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
}

// Dictionary utility operator for adding the contents of the right to the left

func += <K, V> (inout left: [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}