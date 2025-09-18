//
//  MockFavoritesService.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine

// MARK: - Mock Favorites Service for Testing
class MockFavoritesService: FavoritesServiceProtocol {
    private var favorites: [APODModel] = []
    
    func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            if self?.favorites.contains(where: { $0.date == apod.date }) == false {
                self?.favorites.append(apod)
                promise(.success(true))
            } else {
                promise(.success(false))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            if let index = self?.favorites.firstIndex(where: { $0.date == apod.date }) {
                self?.favorites.remove(at: index)
                promise(.success(true))
            } else {
                promise(.success(false))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            let isFav = self?.favorites.contains(where: { $0.date == apod.date }) ?? false
            promise(.success(isFav))
        }
        .eraseToAnyPublisher()
    }
    
    func fetchFavorites() -> AnyPublisher<[APODModel], Error> {
        return Future<[APODModel], Error> { [weak self] promise in
            promise(.success(self?.favorites ?? []))
        }
        .eraseToAnyPublisher()
    }
}
