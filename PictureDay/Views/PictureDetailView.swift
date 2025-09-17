//
//  PictureDetailView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI
import Combine

struct PictureDetailView: View {
    let apod: APODResponse
    let favoritesService: FavoritesServiceProtocol
    
    @StateObject private var viewModel: APODDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullImage = false
    
    init(apod: APODResponse, favoritesService: FavoritesServiceProtocol) {
        self.apod = apod
        self.favoritesService = favoritesService
        self._viewModel = StateObject(wrappedValue: APODDetailViewModel(apod: apod, favoritesService: favoritesService))
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

// MARK: - Detail View Model
@MainActor
class APODDetailViewModel: ObservableObject {
    @Published var isFavorite = false
    
    private let apod: APODResponse
    private let favoritesService: FavoritesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apod: APODResponse, favoritesService: FavoritesServiceProtocol) {
        self.apod = apod
        self.favoritesService = favoritesService
    }
    
    func checkFavoriteStatus() {
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
    
    func toggleFavorite() {
        if isFavorite {
            removeFromFavorites()
        } else {
            addToFavorites()
        }
    }
    
    private func addToFavorites() {
        favoritesService.addToFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] success in
                    if success {
                        self?.isFavorite = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func removeFromFavorites() {
        favoritesService.removeFromFavorites(apod)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] success in
                    if success {
                        self?.isFavorite = false
                    }
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let url: String
    let hdurl: String?
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastOffset.width + value
                            }
                            .onEnded { value in
                                lastOffset = offset
                                if scale < 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { value in
                                lastOffset = offset
                            }
                    )
            } else if isLoading {
                ProgressView("Carregando...")
                    .foregroundColor(.white)
                    .font(.headline)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Erro ao carregar imagem")
                        .foregroundColor(.white)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let imageURLString = hdurl ?? url
        guard let imageURL = URL(string: imageURLString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let uiImage = UIImage(data: data) {
                    self.image = uiImage
                }
                self.isLoading = false
            }
        }.resume()
    }
}

#Preview {
    let sampleAPOD = APODResponse(
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
