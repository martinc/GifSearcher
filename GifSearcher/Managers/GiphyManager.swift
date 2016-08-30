//
//  GiphyManager.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/29/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation
import Alamofire

typealias GifCompletion = [GiphyGif] -> Void

class GiphyManager {
    
    // Singleton
    
    static let sharedInstance = GiphyManager()
    private init() {}
    
    // Fetch Trending GIFs
    
    func fetchTrendingGifs(limit: Int = 10, completion: GifCompletion) {
        giphyGetRequest(GiphyConfig.Endpoints.trending,
                        customParams: [GiphyConfig.Params.limit: limit]) { response in
            switch response.result {
            case .Success(let data):
                if let jsonDictionary = data as? JSONObject {
                    let gifs = GiphyGif.listFromResponse(jsonDictionary)
                    NSLog("Giphy trending success: \(gifs)")
                    completion(gifs)
                }
            case .Failure(let error):
                NSLog("Giphy error: \(error)")
                completion([])
            }
        }
    }
    
    // Search for GIFs
    
    func searchForGifs(searchTerm: String, limit: Int = 10, completion: GifCompletion) {
        giphyGetRequest(GiphyConfig.Endpoints.search,
                        customParams: [
                            GiphyConfig.Params.limit: limit,
                            GiphyConfig.Params.search: searchTerm ]) { response in
            switch response.result {
            case .Success(let data):
                if let jsonDictionary = data as? JSONObject {
                    let gifs = GiphyGif.listFromResponse(jsonDictionary)
                    NSLog("Giphy search success: \(gifs)")
                    completion(gifs)
                }
            case .Failure(let error):
                NSLog("Giphy error: \(error)")
                completion([])
            }
        }
    }

    
    private func giphyGetRequest(endpoint: String, customParams: [String: AnyObject]? = nil, completion: Response<AnyObject, NSError> -> Void) {
        let url = GiphyConfig.host + endpoint
        var params: [String: AnyObject] = [GiphyConfig.Params.apiKey: GiphyConfig.apiKey]
        if let customParams = customParams {
            params += customParams
        }
        Alamofire.request(.GET, url, parameters: params).responseJSON(completionHandler: completion)
    }
    
}

// Dictionary utility operator for adding the contents of the right to the left

func += <K, V> (inout left: [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}