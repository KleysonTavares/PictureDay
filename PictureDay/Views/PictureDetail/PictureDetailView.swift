//
//  PictureDetailView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI
import Combine

struct PictureDetailView: View {
    let apod: APODModel
    let favoritesService: FavoritesServiceProtocol
    
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullImage = false
    
    init(apod: APODModel, favoritesService: FavoritesServiceProtocol) {
        self.apod = apod
        self.favoritesService = favoritesService
        self._viewModel = StateObject(wrappedValue: DetailViewModel(apod: apod, favoritesService: favoritesService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Imagem principal
                        Button(action: {
                            showingFullImage = true
                        }) {
                            APODImageView(url: apod.url, hdurl: apod.hdurl)
                                .frame(maxHeight: 400)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Título e botão de favorito
                            HStack {
                                Text(apod.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.toggleFavorite()
                                }) {
                                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isFavorite ? .red : .white)
                                        .font(.title2)
                                }
                            }
                            
                            // Data
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text(formatDate(apod.date))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            // Tipo de mídia
                            HStack {
                                Image(systemName: apod.mediaType == "image" ? "photo" : "video")
                                    .foregroundColor(.blue)
                                Text(apod.mediaType == "image" ? "Imagem" : "Vídeo")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            // Descrição
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descrição")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(apod.explanation)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineLimit(nil)
                            }
                            
                            // Botão para imagem HD (se disponível)
                            if let hdurl = apod.hdurl, apod.mediaType == "image" {
                                Button(action: {
                                    if let url = URL(string: hdurl) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.right.square")
                                        Text("Ver em Alta Resolução")
                                    }
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .fullScreenCover(isPresented: $showingFullImage) {
                FullScreenImageView(url: apod.url, hdurl: apod.hdurl)
            }
        }
        .onAppear {
            viewModel.checkFavoriteStatus()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleAPOD = APODModel(
        date: "2024-01-01",
        explanation: "Esta é uma descrição de exemplo para a foto do dia da NASA.",
        hdurl: "https://example.com/hd-image.jpg",
        mediaType: "image",
        serviceVersion: "v1",
        title: "Foto de Exemplo da NASA",
        url: "https://example.com/image.jpg"
    )
    
    return PictureDetailView(apod: sampleAPOD, favoritesService: MockFavoritesService())
}
