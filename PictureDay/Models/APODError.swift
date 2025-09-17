//
//  APODError.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation

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
