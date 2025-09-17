//
//  APODMainView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct PictureDayView: View {
    @StateObject private var viewModel: PictureDayViewModel
    @State private var showingDatePicker = false
    
    init(favoritesService: FavoritesServiceProtocol) {
        self._viewModel = StateObject(wrappedValue: PictureDayViewModel(favoritesService: favoritesService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Carregando...")
                        .foregroundColor(.white)
                        .font(.headline)
                } else if let apod = viewModel.currentAPOD {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Imagem principal
                            APODImageView(url: apod.url, hdurl: apod.hdurl)
                                .frame(maxHeight: 400)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // Título e botão de favorito
                                HStack {
                                    Text(apod.title)
                                        .font(.title2)
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
                                Text(formatDateString(apod.date))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                // Descrição
                                Text(apod.explanation)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineLimit(nil)
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Erro")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Tentar Novamente") {
                            viewModel.fetchAPOD()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Foto do Dia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anterior") {
                        viewModel.goToPreviousDay()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Próximo") {
                        viewModel.goToNextDay()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Button(formatDate(viewModel.selectedDate)) {
                        showingDatePicker = true
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePicker("Selecionar Data", selection: $viewModel.selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            viewModel.fetchAPOD()
        }
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    internal func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
}

// MARK: - APOD Image View
struct APODImageView: View {
    let url: String
    let hdurl: String?
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
                    .frame(height: 200)
            } else {
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Erro ao carregar imagem")
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageURL = URL(string: url) else {
            error = TypeError.invalidURL
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error
                    self.isLoading = false
                    return
                }
                
                guard let data = data, let uiImage = UIImage(data: data) else {
                    self.error = TypeError.noData
                    self.isLoading = false
                    return
                }
                
                self.image = uiImage
                self.isLoading = false
            }
        }.resume()
    }
}

#Preview {
    PictureDayView(favoritesService: MockFavoritesService())
}
