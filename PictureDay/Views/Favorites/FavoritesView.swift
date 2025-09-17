//
//  FavoritesView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    @State private var selectedAPOD: APODModel?
    
    init(favoritesService: FavoritesServiceProtocol) {
        self._viewModel = StateObject(wrappedValue: FavoritesViewModel(favoritesService: favoritesService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Carregando favoritos...")
                        .foregroundColor(.white)
                        .font(.headline)
                } else if viewModel.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Nenhum favorito ainda")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Toque no coração nas fotos para adicionar aos favoritos")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(viewModel.favorites) { apod in
                            FavoriteRowView(
                                apod: apod,
                                onTap: {
                                    selectedAPOD = apod
                                },
                                onRemove: {
                                    viewModel.removeFromFavorites(apod)
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchFavorites()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.fetchFavorites()
            }
            .sheet(item: $selectedAPOD) { apod in
                PictureDetailView(apod: apod, favoritesService: MockFavoritesService())
            }
        }
    }
}

#Preview {
    FavoritesView(favoritesService: MockFavoritesService())
}
