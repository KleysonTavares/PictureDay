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
    func fetchAPOD(for date: Date?) -> AnyPublisher<APODModel, TypeError>
    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODModel], TypeError>
    func fetchAPODByCount(count:Int) -> AnyPublisher<[APODModel], TypeError>
}

// MARK: - APOD Service Implementation
class APODService: APODServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetchAPOD(for date: Date? = nil) -> AnyPublisher<APODModel, TypeError> {
        guard let url = ServiceConfig.url(for: date) else {
            return Fail(error: TypeError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: APODModel.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return TypeError.decodingError
                } else {
                    return TypeError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODModel], TypeError> {
        guard let url = ServiceConfig.url(for: nil) else {
            return Fail(error: TypeError.invalidURL)
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
            return Fail(error: TypeError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: finalURL)
            .map(\.data)
            .decode(type: [APODModel].self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return TypeError.decodingError
                } else {
                    return TypeError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchAPODByCount(count: Int) -> AnyPublisher<[APODModel], TypeError> {
        var components = URLComponents(string: ServiceConfig.baseURL)
        var queryItems = [
            URLQueryItem(name: "api_key", value: ServiceConfig.apiKey),
            URLQueryItem(name: "count", value: "\(count)")
        ]
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return Fail(error: TypeError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [APODModel].self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return TypeError.decodingError
                } else {
                    return TypeError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
