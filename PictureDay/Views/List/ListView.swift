//
//  APODListView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    @State private var selectedAPOD: APODModel?
    private let favoritesService: FavoritesServiceProtocol
    
    init(favoritesService: FavoritesServiceProtocol) {
        self.favoritesService = favoritesService
        self._viewModel = StateObject(wrappedValue: ListViewModel(favoritesService: favoritesService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.apodList.isEmpty && viewModel.isLoading {
                    ProgressView("Carregando fotos...")
                        .foregroundColor(.white)
                        .font(.headline)
                } else if viewModel.apodList.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Nenhuma foto encontrada")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button("Recarregar") {
                            viewModel.fetchAPODList()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.apodList) { apod in
                            ListRowView(
                                apod: apod,
                                isFavorite: viewModel.isFavorite(apod),
                                onFavoriteToggle: {
                                    viewModel.toggleFavorite(for: apod)
                                },
                                onTap: {
                                    selectedAPOD = apod
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if apod.id == viewModel.apodList.last?.id {
                                    viewModel.fetchAPODList()
                                }
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listStyle(PlainListStyle())
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
            .navigationTitle("Fotos da NASA")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if viewModel.apodList.isEmpty {
                    viewModel.fetchAPODList()
                }
            }
            .sheet(item: $selectedAPOD) { apod in
                PictureDetailView(apod: apod, favoritesService: favoritesService)
            }
        }
    }
}
