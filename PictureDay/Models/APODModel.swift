//
//  APODModel.swift
//  PictureDay
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Foundation

struct APODModel: Codable, Identifiable {
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String?
    var id: String { date }
    
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
