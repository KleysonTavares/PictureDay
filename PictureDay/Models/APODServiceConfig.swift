//
//  APODServiceConfig.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation

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
