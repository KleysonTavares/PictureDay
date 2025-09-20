//
//  LaunchScreenView.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 20/09/25.
//

import SwiftUI

struct LaunchScreenView: View {
    let favoritesService: FavoritesServiceProtocol
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8

    var body: some View {
        if isActive {
            ContentView()
                .environment(\.managedObjectContext, (favoritesService as! FavoritesService).context)
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    Image("apod")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 1.0
                                self.opacity = 1.0
                            }
                        }

                    Text("Astronomy Picture of the Day")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
