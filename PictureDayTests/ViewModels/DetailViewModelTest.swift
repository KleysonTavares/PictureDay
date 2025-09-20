//
//  DetailViewModelTest.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 18/09/25.
//

import XCTest
import Combine
@testable import PictureDay

@MainActor
final class DetailViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables = nil
    }

     func testcheckisFavorite() throws {
        let expectation = XCTestExpectation(description: "Check favorite status for a favorite item")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-01", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        
        mockFavoritesService.addToFavorites(apod).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)

        let viewModel = DetailViewModel(apod: apod, favoritesService: mockFavoritesService)
        
        viewModel.checkFavoriteStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(viewModel.isFavorite)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testnotFavorite() throws {
        let expectation = XCTestExpectation(description: "Check favorite status for a non-favorite item")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-02", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        
        let viewModel = DetailViewModel(apod: apod, favoritesService: mockFavoritesService)
        
        viewModel.checkFavoriteStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isFavorite)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }

    func testaddsToFavorites() throws {
        let expectation = XCTestExpectation(description: "Toggle adds to favorites")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-03", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        let viewModel = DetailViewModel(apod: apod, favoritesService: mockFavoritesService)
        
        XCTAssertFalse(viewModel.isFavorite)
        
        viewModel.toggleFavorite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(viewModel.isFavorite)
            
            mockFavoritesService.isFavorite(apod)
                .sink(receiveCompletion: {_ in}, receiveValue: { isFav in
                    XCTAssertTrue(isFav)
                    expectation.fulfill()
                }).store(in: &self.cancellables)
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testremovesFromFavorites() throws {
        let expectation = XCTestExpectation(description: "Toggle removes from favorites")
        let mockFavoritesService = MockFavoritesService()
        let apod = APODModel(date: "2024-01-04", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        let viewModel = DetailViewModel(apod: apod, favoritesService: mockFavoritesService)

        viewModel.isFavorite = true
        mockFavoritesService.addToFavorites(apod).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)

        viewModel.toggleFavorite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isFavorite)
            
            mockFavoritesService.isFavorite(apod)
                .sink(receiveCompletion: {_ in}, receiveValue: { isFav in
                    XCTAssertFalse(isFav)
                    expectation.fulfill()
                }).store(in: &self.cancellables)
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
}
