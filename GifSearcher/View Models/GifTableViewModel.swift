//
//  GifTableViewModel.swift
//  GifSearcher
//
//  Created by Martin Ceperley on 9/1/16.
//  Copyright © 2016 Emergence Studios LLC. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GifTableViewModel {
    
    let searchQuery: Variable<String>
    
    let gifResults: Observable<[GifCellViewModel]>
    
    init() {
        
        searchQuery = Variable("")
        
        gifResults = searchQuery.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[GifCellViewModel]> in
                
                let gifsObservable: Observable<[GiphyGif]>
                if query.isEmpty {
                    gifsObservable = GiphyManager.sharedInstance.fetchTrendingGifs()
                } else {
                    gifsObservable = GiphyManager.sharedInstance.searchForGifs(query)
                }
                
                return gifsObservable.map { gifs -> [GifCellViewModel] in
                    return gifs.map { GifCellViewModel(gif: $0) }
                }
                
            }.observeOn(MainScheduler.instance)
    }
    
}