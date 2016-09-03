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
    let loadNextPageTrigger: Observable<Void>
    var gifResults: Observable<[GifCellViewModel]>?

    let pageSize = 10
    
    
    init(loadNextPageTrigger: Observable<Void>) {
        self.loadNextPageTrigger = loadNextPageTrigger
        searchQuery = Variable("")
        setupBindings()
    }
    
    func setupBindings() {
        gifResults = searchQuery.asObservable()
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[GifCellViewModel]> in
                return self.requestGifPage([], query: query, page: 0)
            }
            .observeOn(MainScheduler.instance)
    }

    // Requests a page of GIFs from the API. loadNextPageTrigger will trigger the next page.
    
    private func requestGifPage(loaded: [GifCellViewModel], query: String, page: Int) -> Observable<[GifCellViewModel]> {
    
        let gifsObservable: Observable<[GiphyGif]>
        let giphy = GiphyManager.sharedInstance
        if query.isEmpty {
            gifsObservable = giphy.fetchTrendingGifs(pageSize, offset: pageSize * page)
        } else {
            gifsObservable = giphy.searchForGifs(query, limit: pageSize, offset: pageSize * page)
        }
        
        let gifModelsObservable = gifsObservable.map { gifs -> [GifCellViewModel] in
            return gifs.map { GifCellViewModel(gif: $0) }
        }
        
        return gifModelsObservable.flatMap({ (viewModels) -> Observable<[GifCellViewModel]> in
            var allGifs = loaded
            allGifs.appendContentsOf(viewModels)

            return [
                Observable.just(allGifs),
                Observable.never().takeUntil(self.loadNextPageTrigger),
                self.requestGifPage(allGifs, query: query, page: page + 1)
            ].concat()
        })
    }
    
}