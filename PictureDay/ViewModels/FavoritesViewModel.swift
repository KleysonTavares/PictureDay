//
//  FavoritesViewModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Favorites View Model
@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [APODResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesService: FavoritesServiceProtocol) {
        self.favoritesService = favoritesService
    }
    
    func fetchFavorites() {
        isLoading = true
        errorMessage = nil
        
        favoritesService.fetchFavorites()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] favorites in
                    self?.favorites = favorites
                }
            )
            .store(in: &cancellables)
    }
    
    func removeFromFavorites(_ apod: APODResponse) {
        favoritesService.removeFromFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erro ao remover dos favoritos: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.favorites.removeAll { $0.date == apod.date }
                    }
                }
            )
            .store(in: &cancellables)
    }
}
