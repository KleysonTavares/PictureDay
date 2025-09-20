//
//  PictureDayApp.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import CoreData
import SwiftUI

@main
struct PictureDayApp: App {
    let persistenceController = PersistenceController.shared
    
    private var favoritesService: FavoritesService {
           FavoritesService(context: persistenceController.container.viewContext)
       }
    
    var body: some Scene {
            WindowGroup {
                LaunchScreenView(favoritesService: favoritesService)
            }
        }
}
