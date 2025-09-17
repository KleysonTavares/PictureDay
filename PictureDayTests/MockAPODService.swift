//
//  MockAPODService.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 16/09/25.
//

import Combine
import Foundation
@testable import PictureDay

class MockAPODService: APODServiceProtocol {
    private let mockData: [APODModel]

    init(mockData: [APODModel] = []) {
        self.mockData = mockData
    }

    func fetchAPOD(for date: Date? = nil) -> AnyPublisher<APODModel, TypeError> {
        if let firstItem = mockData.first {
            return Just(firstItem)
                .setFailureType(to: TypeError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TypeError.noData)
                .eraseToAnyPublisher()
        }
    }

    func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODModel], TypeError> {
        return Just(mockData)
            .setFailureType(to: TypeError.self)
            .eraseToAnyPublisher()
    }
}
