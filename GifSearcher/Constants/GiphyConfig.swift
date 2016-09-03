//
//  GiphyConfig.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/30/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation

// Configuration

enum GiphyEndpoint: String {
    case Trending = "/gifs/trending"
    case Search = "/gifs/search"
}

struct GiphyConfig {
    static let apiKey = "dc6zaTOxFJmzC"
    static let host = "http://api.giphy.com"
    static let apiVersion = "/v1"
    
    struct Params {
        static let apiKey = "api_key"
        static let limit = "limit"
        static let offset = "offset"
        static let search = "q"
    }
    
    struct Properties {
        static let id = "id"
        static let data = "data"
        static let images = "images"
        static let rendition = "fixed_height"
        static let height = "height"
        static let width = "width"
        static let mp4 = "mp4"
    }
}

