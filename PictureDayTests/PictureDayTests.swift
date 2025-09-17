//
//  PictureDayTests.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 16/09/25.
//

import XCTest
import Combine
@testable import PictureDay

final class PictureDayTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables = nil
    }

    // MARK: - APOD Service Tests
    func testAPODServiceFetchAPOD() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD")
        let service = APODService()
        
        service.fetchAPOD()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { apod in
                    XCTAssertNotNil(apod)
                    XCTAssertFalse(apod.title.isEmpty)
                    XCTAssertFalse(apod.explanation.isEmpty)
                    XCTAssertFalse(apod.date.isEmpty)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAPODServiceInvalidURL() throws {
        let expectation = XCTestExpectation(description: "Invalid URL")
        let service = APODService()
        
        // Test with invalid date that should cause URL creation to fail
        let invalidDate = Date(timeIntervalSince1970: -1) // Very old date
        
        service.fetchAPOD(for: invalidDate)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertTrue(error is APODError)
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected failure")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Mock Service Tests
    func testMockAPODService() throws {
        let mockData = [
            APODResponse(
                date: "2024-01-01",
                explanation: "Test explanation",
                hdurl: "https://example.com/hd.jpg",
                mediaType: "image",
                serviceVersion: "v1",
                title: "Test Title",
                url: "https://example.com/image.jpg"
            )
        ]
        
        let mockService = MockAPODService(mockData: mockData)
        let expectation = XCTestExpectation(description: "Mock fetch")
        
        mockService.fetchAPOD()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { apod in
                    XCTAssertEqual(apod.title, "Test Title")
                    XCTAssertEqual(apod.date, "2024-01-01")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Favorites Service Tests
    func testMockFavoritesService() throws {
        let mockService = MockFavoritesService()
        let expectation = XCTestExpectation(description: "Mock favorites")
        
        let testAPOD = APODResponse(
            date: "2024-01-01",
            explanation: "Test explanation",
            hdurl: nil,
            mediaType: "image",
            serviceVersion: "v1",
            title: "Test Title",
            url: "https://example.com/image.jpg"
        )
        
        // Test adding to favorites
        mockService.addToFavorites(testAPOD)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got error: \(error)")
                    }
                },
                receiveValue: { success in
                    XCTAssertTrue(success)
                    
                    // Test checking if favorite
                    mockService.isFavorite(testAPOD)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    XCTFail("Expected success, got error: \(error)")
                                }
                            },
                            receiveValue: { isFavorite in
                                XCTAssertTrue(isFavorite)
                                
                                // Test fetching favorites
                                mockService.fetchFavorites()
                                    .sink(
                                        receiveCompletion: { completion in
                                            if case .failure(let error) = completion {
                                                XCTFail("Expected success, got error: \(error)")
                                            }
                                            expectation.fulfill()
                                        },
                                        receiveValue: { favorites in
                                            XCTAssertEqual(favorites.count, 1)
                                            XCTAssertEqual(favorites.first?.title, "Test Title")
                                        }
                                    )
                                    .store(in: &self.cancellables)
                            }
                        )
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - APOD Model Tests
    func testAPODResponseDecoding() throws {
        let json = """
        {
            "date": "2024-01-01",
            "explanation": "Test explanation",
            "hdurl": "https://example.com/hd.jpg",
            "media_type": "image",
            "service_version": "v1",
            "title": "Test Title",
            "url": "https://example.com/image.jpg"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let apod = try decoder.decode(APODResponse.self, from: data)
        
        XCTAssertEqual(apod.date, "2024-01-01")
        XCTAssertEqual(apod.explanation, "Test explanation")
        XCTAssertEqual(apod.hdurl, "https://example.com/hd.jpg")
        XCTAssertEqual(apod.mediaType, "image")
        XCTAssertEqual(apod.serviceVersion, "v1")
        XCTAssertEqual(apod.title, "Test Title")
        XCTAssertEqual(apod.url, "https://example.com/image.jpg")
    }
    
    // MARK: - APOD Service Config Tests
    func testAPODServiceConfigURL() throws {
        let url = APODServiceConfig.url()
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("api.nasa.gov") == true)
        XCTAssertTrue(url?.absoluteString.contains("api_key") == true)
    }
    
    func testAPODServiceConfigURLWithDate() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01
        let url = APODServiceConfig.url(for: testDate)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("date=2022-01-01") == true)
    }
}
