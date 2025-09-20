//
//  FavoriteRowView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import SwiftUI

struct FavoriteRowView: View {
    let apod: APODModel
    let onTap: () -> Void
    let onRemove: () -> Void
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Group {
                    if let image = imageLoader.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if imageLoader.isLoading {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(apod.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatDate(apod.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(apod.explanation)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: {
                    onRemove()
                }) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            imageLoader.loadImage(from: apod.url)
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
