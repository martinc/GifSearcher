//
//  GiphyConfig.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/30/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation

// Configuration

struct GiphyConfig {
    static let apiKey = "dc6zaTOxFJmzC"
    static let host = "http://api.giphy.com"
    
    struct Endpoints {
        static let trending = "/v1/gifs/trending"
        static let search = "/v1/gifs/search"
    }
    
    struct Params {
        static let apiKey = "api_key"
        static let limit = "limit"
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

