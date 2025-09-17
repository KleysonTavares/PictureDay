//
//  APODModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation

// MARK: - APOD Response Model
struct APODResponse: Codable, Identifiable {
    let id = UUID()
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
    }
}

// MARK: - APOD Error Model
enum APODError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "Nenhum dado recebido"
        case .decodingError:
            return "Erro ao decodificar dados"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .invalidDate:
            return "Data inválida"
        }
    }
}

// MARK: - APOD Service Configuration
struct APODServiceConfig {
    static let baseURL = "https://api.nasa.gov/planetary/apod"
    static let apiKey = "DbVfQ2rMC5rBVbcxaLMl8PTbi6jzvFkn06buczec"
    
    static func url(for date: Date? = nil) -> URL? {
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
