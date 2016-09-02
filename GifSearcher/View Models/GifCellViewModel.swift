//
//  GifCellViewModel.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 9/1/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation

class GifCellViewModel {
    
    let gif: GiphyGif
    
    init(gif: GiphyGif) {
        self.gif = gif
    }
    
    var videoURL: NSURL? {
        return NSURL(string: gif.mp4URL)
    }
    
}