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
    @Published var apodList: [APODModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteStatuses: [String: Bool] = [:]
    
    private let apodService: APODServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentDate = Date()
    private let fetchCount = 10
    
    init(apodService: APODServiceProtocol = APODService(),
         favoritesService: FavoritesServiceProtocol) {
        self.apodService = apodService
        self.favoritesService = favoritesService
    }
    
    func fetchAPODList() {
        isLoading = true
        errorMessage = nil
        
        let endDate = currentDate
        let startDate = Calendar.current.date(byAdding: .day, value: -19, to: endDate) ?? endDate
        
        apodService.fetchAPODByCount(count: fetchCount)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] apodList in
                    guard let self = self else { return }
                    
                    let newItems = apodList.filter { newItem in
                        !self.apodList.contains(where: { $0.date == newItem.date })
                    }
                    self.apodList.append(contentsOf: newItems)
                    self.apodList.sort { $0.date > $1.date }
                    self.checkFavoriteStatuses()
                    
                    if let oldestDateString = apodList.sorted(by: { $0.date < $1.date }).first?.date,
                        let oldestDate = self.dateFormatter().date(from: oldestDateString) {
                        self.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: oldestDate) ?? Date()
                    }
                }
            )
            .store(in: &cancellables)
            }
    
    func toggleFavorite(for apod: APODModel) {
        let isCurrentlyFavorite = favoriteStatuses[apod.date] ?? false
        
        if isCurrentlyFavorite {
            removeFromFavorites(apod)
        } else {
            addToFavorites(apod)
        }
    }
    
    private func addToFavorites(_ apod: APODModel) {
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
    
    private func removeFromFavorites(_ apod: APODModel) {
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
    
    func isFavorite(_ apod: APODModel) -> Bool {
        return favoriteStatuses[apod.date] ?? false
    }
    
    func dateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }
}
