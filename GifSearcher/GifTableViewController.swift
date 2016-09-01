//
//  GifTableViewController.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 8/29/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GifTableViewController: UIViewController {

    // UI
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Plain)
    private let searchController = UISearchController(searchResultsController: nil)

    private let rowHeight: CGFloat = 200.0
    
    // Data binding
    
    private let disposeBag = DisposeBag()
    private let searchQuery = Variable("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchController()
        setupDataBinding()
        setupEventHandling()
    }
    
    private func setupTableView() {
        tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.rowHeight = rowHeight
        tableView.registerClass(GifCell.self, forCellReuseIdentifier: GifCell.resuseIdentifier)
    }
    
    private func setupSearchController() {
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setupDataBinding() {
        
        // Bind search bar text to our searchQuery Variable
        
        searchController.searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { (query: String) -> Void in
                self.searchQuery.value = query
            }.addDisposableTo(disposeBag)

        // Turn our searchQuery Variable into API Requests
        
        let gifResults = self.searchQuery.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[GiphyGif]> in
                if query.isEmpty {
                    return GiphyManager.sharedInstance.fetchTrendingGifs()
                } else {
                    return GiphyManager.sharedInstance.searchForGifs(query)
                }
        }.observeOn(MainScheduler.instance)
        
        // Bind our API responses to table view cells
        
        gifResults
            .bindTo(tableView.rx_itemsWithCellIdentifier(GifCell.resuseIdentifier, cellType: GifCell.self)) {
                (row, gif, cell) in
                cell.textLabel?.text = gif.id
                cell.gif = gif
            }
            .addDisposableTo(disposeBag)

    }
    
    private func setupEventHandling() {
        
        // Play movies when the cells appear
        
        tableView.rx_willDisplayCell.subscribeNext { cell, indexPath in
            if let gifCell = cell as? GifCell {
                gifCell.play()
            }
        }.addDisposableTo(disposeBag)
        
        // Stop movies when cells dissapear
        
        tableView.rx_didEndDisplayingCell.subscribeNext { cell, indexPath in
            if let gifCell = cell as? GifCell {
                gifCell.stopPlaying()
            }
        }.addDisposableTo(disposeBag)
        
        
        // When search controller dismisses, clear searchQuery Variable
        
        searchController.rx_willDismiss.subscribeNext {
            self.searchQuery.value = ""
        }.addDisposableTo(disposeBag)

    }
}

