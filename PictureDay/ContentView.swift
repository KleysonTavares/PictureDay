//
//  ContentView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    private var favoritesService: FavoritesService {
        FavoritesService(context: viewContext)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            PictureDayView(favoritesService: favoritesService)
                .tabItem {
                    Image(systemName: "photo")
                    Text("Foto do Dia")
                }
                .tag(0)
            
            ListView(favoritesService: favoritesService)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lista")
                }
                .tag(1)
            
            FavoritesView(favoritesService: favoritesService)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoritos")
                }
                .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
