//
//  FullScreenImageView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import SwiftUI

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
