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
        
        GiphyManager.sharedInstance.searchForGifs("cats") { gifs in
            print("Got \(gifs.count) GIFs to diplay")
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

