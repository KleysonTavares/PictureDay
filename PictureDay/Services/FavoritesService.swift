//
//  FavoritesService.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import CoreData
import Combine

protocol FavoritesServiceProtocol {
    func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error>
    func fetchFavorites() -> AnyPublisher<[APODModel], Error>
}

class FavoritesService: FavoritesServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            self.context.perform {
                let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
                request.predicate = NSPredicate(format: "date == %@", apod.date)
                
                do {
                    let existing = try self.context.fetch(request)
                    if existing.isEmpty {
                        let fav = FavoriteAPOD(context: self.context)
                        fav.date = apod.date
                        fav.explanation = apod.explanation
                        fav.hdurl = apod.hdurl
                        fav.mediaType = apod.mediaType
                        fav.title = apod.title
                        fav.url = apod.url
                        fav.favoriteDate = Date()
                        try self.context.save()
                        promise(.success(true))
                    } else {
                        promise(.success(false))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            self.context.perform {
                let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
                request.predicate = NSPredicate(format: "date == %@", apod.date)
                
                do {
                    if let fav = try self.context.fetch(request).first {
                        self.context.delete(fav)
                        try self.context.save()
                        promise(.success(true))
                    } else {
                        promise(.success(false))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            self.context.perform {
                let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
                request.predicate = NSPredicate(format: "date == %@", apod.date)
                
                do {
                    let favorites = try self.context.fetch(request)
                    promise(.success(!favorites.isEmpty))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchFavorites() -> AnyPublisher<[APODModel], Error> {
        Future<[APODModel], Error> { [weak self] promise in
            guard let self = self else { return }
            self.context.perform {
                let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteAPOD.favoriteDate, ascending: false)]
                
                do {
                    let favorites = try self.context.fetch(request)
                    let models = favorites.map { fav in
                        APODModel(
                            date: fav.date ?? "",
                            explanation: fav.explanation ?? "",
                            hdurl: fav.hdurl,
                            mediaType: fav.mediaType ?? "",
                            serviceVersion: "v1",
                            title: fav.title ?? "",
                            url: fav.url ?? ""
                        )
                    }
                    promise(.success(models))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
