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
    
    // View Model
    
    private let viewModel = GifTableViewModel()

    // UI
    
    private let tableView = UITableView(frame: CGRect.zero, style: .Plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let rowHeight: CGFloat = 200.0
    
    // Data binding
    
    private let disposeBag = DisposeBag()
    
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
        
        // Bind search bar text to searchQuery Variable
        
        searchController.searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { (query: String) -> Void in
                self.viewModel.searchQuery.value = query
            }.addDisposableTo(disposeBag)
        
        
        // Bind GIF Cell Model results to table view cells
        
        viewModel.gifResults
            .bindTo(tableView.rx_itemsWithCellIdentifier(GifCell.resuseIdentifier, cellType: GifCell.self)) {
                (_, gifViewModel, cell) in
                cell.viewModel = gifViewModel
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
            self.viewModel.searchQuery.value = ""
        }.addDisposableTo(disposeBag)

    }
}

