//
//  GifCell.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/31/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import UIKit
import AVFoundation

class GifCell: UITableViewCell {
    
    static let resuseIdentifier = "GifCell"
    
    var player: AVPlayer?
    var videoLayer: AVPlayerLayer?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        
        if let oldLayer = videoLayer {
            oldLayer.removeFromSuperlayer()
            videoLayer = nil
        }
        
        if let oldPlayer = player {
            NSNotificationCenter.defaultCenter()
                .removeObserver(self,
                                name: AVPlayerItemDidPlayToEndTimeNotification,
                                object: oldPlayer.currentItem)
            player = nil
        }
    }

    var viewModel: GifCellViewModel? {
        didSet {
                        
            if let url = viewModel?.videoURL {
                
                let videoPlayer = AVPlayer(URL: url)
                videoPlayer.actionAtItemEnd = .None
                
                NSNotificationCenter.defaultCenter()
                    .addObserver(self,
                                 selector: #selector(playerReachedEnd),
                                 name: AVPlayerItemDidPlayToEndTimeNotification,
                                 object: videoPlayer.currentItem)
                
                let videoLayer = AVPlayerLayer(player: videoPlayer)
                videoLayer.frame = self.contentView.frame
                videoLayer.backgroundColor = UIColor.darkGrayColor().CGColor
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
                self.layer.addSublayer(videoLayer)
                
                self.player = videoPlayer
                self.videoLayer = videoLayer
            }
        }
    }
    
    func play() {
        player?.play()
    }
    
    func stopPlaying() {
        player?.pause()
    }

    func playerReachedEnd(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem {
            item.seekToTime(kCMTimeZero)
        }
    }
}
