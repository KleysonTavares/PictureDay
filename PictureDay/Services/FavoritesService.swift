//
//  FavoritesService.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import CoreData
import Combine

// MARK: - Favorites Service Protocol
protocol FavoritesServiceProtocol {
    func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func fetchFavorites() -> AnyPublisher<[APODModel], Error>
}

// MARK: - Favorites Service Implementation
class FavoritesService: FavoritesServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Context não disponível"])))
                return
            }
            
            // Verificar se já existe
            let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", apod.date)
            
            do {
                let existingFavorites = try self.context.fetch(request)
                if existingFavorites.isEmpty {
                    let favorite = FavoriteAPOD(context: self.context)
                    favorite.date = apod.date
                    favorite.explanation = apod.explanation
                    favorite.hdurl = apod.hdurl
                    favorite.mediaType = apod.mediaType
                    favorite.title = apod.title
                    favorite.url = apod.url
                    favorite.favoriteDate = Date()
                    
                    try self.context.save()
                    promise(.success(true))
                } else {
                    promise(.success(false)) // Já existe
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Context não disponível"])))
                return
            }
            
            let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", apod.date)
            
            do {
                let favorites = try self.context.fetch(request)
                if let favorite = favorites.first {
                    self.context.delete(favorite)
                    try self.context.save()
                    promise(.success(true))
                } else {
                    promise(.success(false)) // Não encontrado
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Context não disponível"])))
                return
            }
            
            let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", apod.date)
            
            do {
                let favorites = try self.context.fetch(request)
                promise(.success(!favorites.isEmpty))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchFavorites() -> AnyPublisher<[APODModel], Error> {
        return Future<[APODModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Context não disponível"])))
                return
            }
            
            let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteAPOD.favoriteDate, ascending: false)]
            
            do {
                let favorites = try self.context.fetch(request)
                let apodResponses = favorites.map { favorite in
                    APODModel(
                        date: favorite.date ?? "",
                        explanation: favorite.explanation ?? "",
                        hdurl: favorite.hdurl,
                        mediaType: favorite.mediaType ?? "",
                        serviceVersion: "v1",
                        title: favorite.title ?? "",
                        url: favorite.url ?? ""
                    )
                }
                promise(.success(apodResponses))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
