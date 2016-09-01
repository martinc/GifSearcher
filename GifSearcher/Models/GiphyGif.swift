//
//  GiphyGif.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/29/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation
import CoreGraphics

typealias JSONObject = [String: AnyObject]

struct GiphyGif {
    let id: String
    let size: CGSize
    let mp4URL: String
    
    init(id: String, size: CGSize, mp4URL: String) {
        self.id = id
        self.size = size
        self.mp4URL = mp4URL
    }
}

// Deserialization

extension GiphyGif {
    
    private static func coerceInt(value: AnyObject?) -> Int? {
        if let i = value as? Int { return i }
        if let s = value as? String { return Int(s) }
        return nil
    }
    
    static func gifFromResponse(responseGif: JSONObject) -> GiphyGif? {
        
        guard let images = responseGif[GiphyConfig.Properties.images] as? JSONObject,
            let rendition = images[GiphyConfig.Properties.rendition] as? JSONObject else {
                return nil
        }
        
        if let gifId = responseGif[GiphyConfig.Properties.id] as? String,
            gifURL = rendition[GiphyConfig.Properties.mp4] as? String,
            gifWidth = coerceInt(rendition[GiphyConfig.Properties.width]),
            gifHeight = coerceInt(rendition[GiphyConfig.Properties.height])
            where !gifURL.isEmpty && gifWidth > 0 && gifHeight > 0
        {
            return GiphyGif(id: gifId,
                            size: CGSize(width: gifWidth, height: gifHeight),
                            mp4URL: gifURL)
        }
        return nil
    }
    
    static func listFromResponse(responseData: JSONObject) -> [GiphyGif] {
        guard let dictList = responseData[GiphyConfig.Properties.data] as? [JSONObject] else {
            return []
        }
        return dictList.flatMap { GiphyGif.gifFromResponse($0) }
    }

}