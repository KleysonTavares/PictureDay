//
//  ImageDayView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct ImageDayView: View {
    let url: String?
    let hdurl: String?
    @StateObject private var imageLoader = ImageLoader()

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if imageLoader.isLoading {
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
            imageLoader.loadImage(from: hdurl ?? url)
        }
    }
}
