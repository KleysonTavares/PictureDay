//
//  APODServiceTests.swift
//  APODServiceTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import XCTest
import Combine
@testable import PictureDay

final class APODServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var sut: APODService!
    private var session: URLSession!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        sut = APODService(session: session)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        sut = nil
        session = nil
        MockURLProtocol.requestHandler = nil
    }

    // MARK: - Testes de Sucesso

    func testFetchAPOD_success() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD success")
        
        let mockAPOD = APODModel(date: "2024-01-01", explanation: "Mock", hdurl: "mock_hd", mediaType: "image", serviceVersion: "v1", title: "Mock Title", url: "mock_url")
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(mockAPOD)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, jsonData)
        }
        
        sut.fetchAPOD()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Esperado sucesso, mas recebeu erro: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { apod in
                XCTAssertEqual(apod.title, "Mock Title")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchAPODRange_success() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD Range success")
        
        let mockList = [
            APODModel(date: "2024-01-02", explanation: "Mock2", hdurl: "mock_hd2", mediaType: "image", serviceVersion: "v1", title: "Mock Title 2", url: "mock_url2"),
            APODModel(date: "2024-01-01", explanation: "Mock1", hdurl: "mock_hd1", mediaType: "image", serviceVersion: "v1", title: "Mock Title 1", url: "mock_url1")
        ]
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(mockList)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, jsonData)
        }
        
        sut.fetchAPODRange(startDate: Date(), endDate: Date())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Esperado sucesso, mas recebeu erro: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { apodList in
                XCTAssertEqual(apodList.count, 2)
                XCTAssertEqual(apodList.first?.title, "Mock Title 2")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }

    // MARK: - Testes de Erro

    func testFetchAPOD_decodingError() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD decoding error")
        
        let invalidJsonData = "{\"not_valid\": \"json\"}".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, invalidJsonData)
        }
        
        sut.fetchAPOD()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error.localizedDescription, TypeError.decodingError.localizedDescription)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Esperado erro, mas recebeu valor")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchAPOD_networkError() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD network error")
        let mockError = NSError(domain: "NSURLErrorDomain", code: -1, userInfo: nil)
        
        MockURLProtocol.requestHandler = { request in
            throw mockError
        }
        
        sut.fetchAPOD()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error.localizedDescription, TypeError.networkError(mockError).localizedDescription)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Esperado erro, mas recebeu valor")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.5)
    }
}
