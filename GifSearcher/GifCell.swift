//
//  GifCell.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/31/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class GifCell: UITableViewCell {
    
    static let resuseIdentifier = "GifCell"
    
    var player: AVPlayer?
    var videoLayer: AVPlayerLayer?
    
    let viewModel: Variable<GifCellViewModel?>

    private let disposeBag = DisposeBag()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.viewModel = Variable(nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = Variable(nil)
        super.init(coder: aDecoder)
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.asDriver().distinctUntilChanged { (oldViewModel, newViewModel) -> Bool in
            if let old = oldViewModel, new = newViewModel {
                return old.gif.id == new.gif.id
            }
            return false
        }.driveNext { viewModel in
            
            // Remove old video layer
            
            if let oldLayer = self.videoLayer {
                oldLayer.removeFromSuperlayer()
            }
            
            // Unsubscribe from old player
            
            if let oldPlayer = self.player {
                NSNotificationCenter.defaultCenter()
                    .removeObserver(self,
                        name: AVPlayerItemDidPlayToEndTimeNotification,
                        object: oldPlayer.currentItem)
            }
            
            // Setup new layer and player
            
            if let url = viewModel?.videoURL, let videoSize = viewModel?.gif.size {
                
                let videoPlayer = AVPlayer(URL: url)
                videoPlayer.actionAtItemEnd = .None
                
                NSNotificationCenter.defaultCenter()
                    .addObserver(self,
                        selector: #selector(self.playerReachedEnd),
                        name: AVPlayerItemDidPlayToEndTimeNotification,
                        object: videoPlayer.currentItem)
                
                let videoLayer = AVPlayerLayer(player: videoPlayer)
                
                let videoRatio = videoSize.height / videoSize.width
                let width = self.contentView.bounds.size.width
                let height = width * videoRatio
                let yOffset = (self.contentView.bounds.size.height - height) / 2.0
                
                videoLayer.frame = CGRect(x: 0,
                    y: yOffset,
                    width: width,
                    height: height)
                
                videoLayer.backgroundColor = UIColor.darkGrayColor().CGColor
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.layer.addSublayer(videoLayer)
                
                self.player = videoPlayer
                self.videoLayer = videoLayer
                
                self.clipsToBounds = true
                self.contentView.backgroundColor = UIColor.darkGrayColor()
            }

        }.addDisposableTo(self.disposeBag)
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
