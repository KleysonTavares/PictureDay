//
//  PictureDayViewModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - APOD View Model
@MainActor
class PictureDayViewModel: ObservableObject {
    @Published var currentAPOD: APODModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFavorite = false
    @Published var selectedDate = Date()
    
    private let apodService: APODServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apodService: APODServiceProtocol = APODService(), 
         favoritesService: FavoritesServiceProtocol) {
        self.apodService = apodService
        self.favoritesService = favoritesService
        
        // Observar mudanças na data selecionada
        $selectedDate
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] date in
                self?.fetchAPOD(for: date)
            }
            .store(in: &cancellables)
    }
    
    func fetchAPOD(for date: Date? = nil) {
        isLoading = true
        errorMessage = nil
        
        apodService.fetchAPOD(for: date)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] apod in
                    self?.currentAPOD = apod
                    self?.checkIfFavorite(apod)
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite() {
        guard let apod = currentAPOD else { return }
        
        if isFavorite {
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
                        self?.isFavorite = true
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
                        self?.isFavorite = false
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func checkIfFavorite(_ apod: APODModel) {
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
    
    func goToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    func goToNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    func goToToday() {
        selectedDate = Date()
    }
}
