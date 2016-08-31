//
//  ViewController.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/29/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = GiphyManager.sharedInstance.searchForGifs("cats").subscribeNext { gifs in
            print("Got \(gifs.count) cat GIFs to diplay")
        }
        
        _ = GiphyManager.sharedInstance.fetchTrendingGifs().subscribeNext { gifs in
            print("Got \(gifs.count) trending GIFs to diplay")
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

