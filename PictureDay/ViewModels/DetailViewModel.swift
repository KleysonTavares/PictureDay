//
//  DetailViewModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    @Published var isFavorite = false
    
    private let apod: APODModel
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apod: APODModel, favoritesService: FavoritesServiceProtocol) {
        self.apod = apod
        self.favoritesService = favoritesService
    }
    
    func checkFavoriteStatus() {
        favoritesService.isFavorite(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] isFav in
                    self?.isFavorite = isFav
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite() {
        if isFavorite {
            removeFromFavorites()
        } else {
            addToFavorites()
        }
    }
    
    private func addToFavorites() {
        favoritesService.addToFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] success in
                    if success {
                        self?.isFavorite = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func removeFromFavorites() {
        favoritesService.removeFromFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] success in
                    if success {
                        self?.isFavorite = false
                    }
                }
            )
            .store(in: &cancellables)
    }
}
