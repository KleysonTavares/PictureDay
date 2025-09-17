//
//  APODService.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation
import Combine

// MARK: - APOD Service Protocol
protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) -> AnyPublisher<APODResponse, APODError>
    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODResponse], APODError>
}

// MARK: - APOD Service Implementation
class APODService: APODServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetchAPOD(for date: Date? = nil) -> AnyPublisher<APODResponse, APODError> {
        guard let url = APODServiceConfig.url(for: date) else {
            return Fail(error: APODError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APODResponse.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return APODError.decodingError
                } else {
                    return APODError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODResponse], APODError> {
        guard let url = APODServiceConfig.url(for: nil) else {
            return Fail(error: APODError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let existingQueryItems = components?.queryItems ?? []
        let newQueryItems = [
            URLQueryItem(name: "start_date", value: formatter.string(from: startDate)),
            URLQueryItem(name: "end_date", value: formatter.string(from: endDate))
        ]
        
        components?.queryItems = existingQueryItems + newQueryItems
        
        guard let finalURL = components?.url else {
            return Fail(error: APODError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: finalURL)
            .map(\.data)
            .decode(type: [APODResponse].self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return APODError.decodingError
                } else {
                    return APODError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock APOD Service for Testing
class MockAPODService: APODServiceProtocol {
    private let mockData: [APODResponse]
    
    init(mockData: [APODResponse] = []) {
        self.mockData = mockData
    }
    
    func fetchAPOD(for date: Date? = nil) -> AnyPublisher<APODResponse, APODError> {
        if let firstItem = mockData.first {
            return Just(firstItem)
                .setFailureType(to: APODError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: APODError.noData)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODResponse], APODError> {
        return Just(mockData)
            .setFailureType(to: APODError.self)
            .eraseToAnyPublisher()
    }
}
