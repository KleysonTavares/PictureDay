//
//  PictureDayViewModelTest.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import XCTest
import Combine
@testable import PictureDay

@MainActor
final class PictureDayViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables = nil
    }
    
    func testFetchAPODSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD success")
        let mockData = APODModel(date: "2024-01-01", explanation: "Test", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test Title", url: "url")
        let mockAPODService = MockAPODService(mockData: [mockData])
        let viewModel = PictureDayViewModel(apodService: mockAPODService, favoritesService: MockFavoritesService())

        viewModel.fetchAPOD()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(viewModel.currentAPOD)
            XCTAssertEqual(viewModel.currentAPOD?.title, "Test Title")
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }
    
    func testFetchAPODFailure() throws {
        let expectation = XCTestExpectation(description: "Fetch APOD failure")
        class MockAPODServiceFailure: APODServiceProtocol {
            func fetchAPOD(for date: Date?) -> AnyPublisher<APODModel, TypeError> {
                return Fail(error: TypeError.networkError(NSError(domain: "test", code: -1))).eraseToAnyPublisher()
            }
            func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODModel], TypeError> {
                return Fail(error: TypeError.networkError(NSError(domain: "test", code: -1))).eraseToAnyPublisher()
            }
        }
        let viewModel = PictureDayViewModel(apodService: MockAPODServiceFailure(), favoritesService: MockFavoritesService())

        viewModel.fetchAPOD()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertNil(viewModel.currentAPOD)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }
    
    func testAddsToFavorites() throws {
        let expectation = XCTestExpectation(description: "Toggle favorite adds item")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-02", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        let viewModel = PictureDayViewModel(apodService: MockAPODService(mockData: [apod]), favoritesService: mockFavoritesService)
        
        viewModel.fetchAPOD()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(viewModel.isFavorite)
            
            viewModel.toggleFavorite()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertTrue(viewModel.isFavorite)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testRemovesFromFavorites() throws {
        let expectation = XCTestExpectation(description: "Toggle favorite removes item")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-03", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        let viewModel = PictureDayViewModel(apodService: MockAPODService(mockData: [apod]), favoritesService: mockFavoritesService)

        viewModel.isFavorite = true
        mockFavoritesService.addToFavorites(apod).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)
        viewModel.fetchAPOD()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(viewModel.isFavorite)
            
            viewModel.toggleFavorite()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertFalse(viewModel.isFavorite)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testGoToPreviousDay() throws {
        let viewModel = PictureDayViewModel(favoritesService: MockFavoritesService())
        let initialDate = viewModel.selectedDate
        
        viewModel.goToPreviousDay()
        let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: initialDate)
        XCTAssertEqual(viewModel.selectedDate, expectedDate)
    }
    
    func testGoToNextDay() throws {
        let viewModel = PictureDayViewModel(favoritesService: MockFavoritesService())
        let initialDate = viewModel.selectedDate
        
        viewModel.goToNextDay()
        let expectedDate = Calendar.current.date(byAdding: .day, value: 1, to: initialDate)
        XCTAssertEqual(viewModel.selectedDate, expectedDate)
    }
    
    func testGoToToday() throws {
        let viewModel = PictureDayViewModel(favoritesService: MockFavoritesService())
        
        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        
        viewModel.goToToday()
        
        XCTAssertTrue(viewModel.isToday())
    }
    
    func testIsToday() throws {
        let viewModel = PictureDayViewModel(favoritesService: MockFavoritesService())
        
        viewModel.selectedDate = Date()
        XCTAssertTrue(viewModel.isToday())
        
        viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(viewModel.isToday())
    }
}
