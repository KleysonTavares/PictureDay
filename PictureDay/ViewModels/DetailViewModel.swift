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
    
    let apod: APODModel
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apod: APODModel, favoritesService: FavoritesServiceProtocol) {
        self.apod = apod
        self.favoritesService = favoritesService
        checkFavoriteStatus()
    }
    
    func checkFavoriteStatus() {
        favoritesService.isFavorite(apod)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("❌ Erro ao checar favorito:", error)
                }
            } receiveValue: { isFav in
                self.isFavorite = isFav
            }
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
            .sink { _ in } receiveValue: { success in
                if success { self.isFavorite = true }
            }
            .store(in: &cancellables)
    }
    
    private func removeFromFavorites() {
        favoritesService.removeFromFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { success in
                if success { self.isFavorite = false }
            }
            .store(in: &cancellables)
    }
}
