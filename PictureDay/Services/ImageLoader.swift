//
//  ImageLoader.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 19/09/25.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellable: AnyCancellable?
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.error = TypeError.invalidURL
            self.image = nil
            self.isLoading = false
            return
        }
        
        isLoading = true
        cancellable = session.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw TypeError.noData
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] image in
                self?.image = image
            })
    }
}
