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
    
    private var viewModel: GifTableViewModel?

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
        
        let loadNextPageTrigger = tableView.rx_willDisplayCell.flatMap { (cell, indexPath) -> Observable<Void> in
            if let rowCount = self.tableView.dataSource?.tableView(self.tableView, numberOfRowsInSection: indexPath.section) {
                if indexPath.row == rowCount - 1 {
                    //Load another page
                    return Observable.just(())
                }
            }
            return Observable.empty()
        }
        
        let viewModel = GifTableViewModel(loadNextPageTrigger: loadNextPageTrigger)
        self.viewModel = viewModel
        
        // Bind GIF Results to table view cells
        
        if let gifResults = viewModel.gifResults {
            gifResults
                .bindTo(tableView.rx_itemsWithCellIdentifier(GifCell.resuseIdentifier, cellType: GifCell.self)) {
                    (row, gifViewModel, cell) in
                    cell.viewModel.value = gifViewModel
                }
                .addDisposableTo(disposeBag)
        }
        
        // Bind search bar text to searchQuery Variable
        
        searchController.searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bindTo(viewModel.searchQuery)
            .addDisposableTo(disposeBag)
        
        // When search controller dismisses, clear searchQuery Variable
        
        searchController.rx_willDismiss.subscribeNext {
            self.viewModel?.searchQuery.value = ""
        }.addDisposableTo(disposeBag)
        
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
    }
}

