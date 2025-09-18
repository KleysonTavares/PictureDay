//
//  ImageDayView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct ImageDayView: View {
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
