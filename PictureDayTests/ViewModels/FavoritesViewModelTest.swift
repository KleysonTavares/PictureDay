//
//  FavoritesViewModelTest.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 18/09/25.
//

import XCTest
import Combine
@testable import PictureDay

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables = nil
    }

    func testFetchFavoritesSuccess() throws {
        let expectation = XCTestExpectation(description: "Fetch favorites success")
        
        let mockFavoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)
        
        let testAPOD1 = APODModel(date: "2024-01-02", explanation: "Exp1", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test1", url: "url1")
        let testAPOD2 = APODModel(date: "2024-01-01", explanation: "Exp2", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test2", url: "url2")
        
        mockFavoritesService.addToFavorites(testAPOD1).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)
        mockFavoritesService.addToFavorites(testAPOD2).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)

        viewModel.fetchFavorites()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.errorMessage)
            XCTAssertEqual(viewModel.favorites.count, 2)
            XCTAssertEqual(viewModel.favorites.first?.date, "2024-01-02")
            XCTAssertEqual(viewModel.favorites.last?.date, "2024-01-01")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchFavoritesFailure() throws {
        let expectation = XCTestExpectation(description: "Fetch favorites failure")
        
        class MockFavoritesServiceFailure: FavoritesServiceProtocol {
            func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
                return Fail(error: NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add"])).eraseToAnyPublisher()
            }
            func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
                return Fail(error: NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to remove"])).eraseToAnyPublisher()
            }
            func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error> {
                return Fail(error: NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to check"])).eraseToAnyPublisher()
            }
            func fetchFavorites() -> AnyPublisher<[APODModel], Error> {
                return Fail(error: NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch"])).eraseToAnyPublisher()
            }
        }
        
        let viewModel = FavoritesViewModel(favoritesService: MockFavoritesServiceFailure())
        
        viewModel.fetchFavorites()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertTrue(viewModel.favorites.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testRemoveFromFavoritesSuccess() throws {
        let expectation = XCTestExpectation(description: "Remove from favorites success")
        
        let mockFavoritesService = MockFavoritesService()
        let viewModel = FavoritesViewModel(favoritesService: mockFavoritesService)

        let testAPOD = APODModel(date: "2024-01-01", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        
        mockFavoritesService.addToFavorites(testAPOD).sink(receiveCompletion: {_ in}, receiveValue: {_ in}).store(in: &cancellables)
        viewModel.favorites = [testAPOD]
        
        XCTAssertEqual(viewModel.favorites.count, 1)

        viewModel.removeFromFavorites(testAPOD)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(viewModel.favorites.isEmpty)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testRemoveFromFavoritesFailure() throws {
        let expectation = XCTestExpectation(description: "Remove from favorites failure")
        
        class MockFavoritesServiceFailure: FavoritesServiceProtocol {
            func addToFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> { return Fail(error: TestError()).eraseToAnyPublisher() }
            func removeFromFavorites(_ apod: APODModel) -> AnyPublisher<Bool, Error> { return Fail(error: TestError()).eraseToAnyPublisher() }
            func isFavorite(_ apod: APODModel) -> AnyPublisher<Bool, Error> { return Fail(error: TestError()).eraseToAnyPublisher() }
            func fetchFavorites() -> AnyPublisher<[APODModel], Error> { return Fail(error: TestError()).eraseToAnyPublisher() }
            
            struct TestError: Error, LocalizedError {
                var errorDescription: String? { "Erro ao remover dos favoritos" }
            }
        }
        
        let viewModel = FavoritesViewModel(favoritesService: MockFavoritesServiceFailure())
        
        let testAPOD = APODModel(date: "2024-01-01", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        
        viewModel.removeFromFavorites(testAPOD)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertEqual(viewModel.errorMessage, "Erro ao remover dos favoritos: Erro ao remover dos favoritos")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
}
