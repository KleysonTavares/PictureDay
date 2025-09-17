//
//  ListViewModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - List View Model
@MainActor
class ListViewModel: ObservableObject {
    @Published var apodList: [APODResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteStatuses: [String: Bool] = [:]
    
    private let apodService: APODServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apodService: APODServiceProtocol = APODService(),
         favoritesService: FavoritesServiceProtocol) {
        self.apodService = apodService
        self.favoritesService = favoritesService
    }
    
    func fetchAPODList() {
        isLoading = true
        errorMessage = nil
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -19, to: endDate) ?? endDate
        
        apodService.fetchAPODRange(startDate: startDate, endDate: endDate)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] apodList in
                    self?.apodList = apodList.sorted { $0.date > $1.date }
                    self?.checkFavoriteStatuses()
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite(for apod: APODResponse) {
        let isCurrentlyFavorite = favoriteStatuses[apod.date] ?? false
        
        if isCurrentlyFavorite {
            removeFromFavorites(apod)
        } else {
            addToFavorites(apod)
        }
    }
    
    private func addToFavorites(_ apod: APODResponse) {
        favoritesService.addToFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erro ao adicionar aos favoritos: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.favoriteStatuses[apod.date] = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func removeFromFavorites(_ apod: APODResponse) {
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
                        self?.favoriteStatuses[apod.date] = false
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func checkFavoriteStatuses() {
        for apod in apodList {
            favoritesService.isFavorite(apod)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] isFavorite in
                        self?.favoriteStatuses[apod.date] = isFavorite
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    func isFavorite(_ apod: APODResponse) -> Bool {
        return favoriteStatuses[apod.date] ?? false
    }
}
