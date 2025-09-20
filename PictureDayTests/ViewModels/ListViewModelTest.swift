//
//  ListViewModelTest.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import XCTest
import Combine
@testable import PictureDay

@MainActor
final class ListViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables = nil
    }

    func testInitialState() throws {
        let viewModel = ListViewModel(favoritesService: MockFavoritesService())
        
        XCTAssertTrue(viewModel.apodList.isEmpty, "A lista de APODs deve estar vazia no início.")
        XCTAssertFalse(viewModel.isLoading, "O estado de carregamento deve ser falso no início.")
        XCTAssertNil(viewModel.errorMessage, "A mensagem de erro deve ser nula no início.")
    }

    func testSuccessWithFilterAndSort() throws {
        let expectation = XCTestExpectation(description: "Carregar lista de APODs com sucesso e filtrar")
        
        let mockData = [
            APODModel(date: "2024-01-03", explanation: "Exp3", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Image 3", url: "url3"),
            APODModel(date: "2024-01-01", explanation: "Exp1", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Image 1", url: "url1"),
            APODModel(date: "2024-01-02", explanation: "Exp2", hdurl: nil, mediaType: "video", serviceVersion: "v1", title: "Video 2", url: nil)
        ]
        
        let mockAPODService = MockAPODService(mockData: mockData)
        let viewModel = ListViewModel(apodService: mockAPODService, favoritesService: MockFavoritesService())
        
        viewModel.fetchAPODList()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.errorMessage)
            XCTAssertEqual(viewModel.apodList.count, 2, "A lista deve ter 2 itens após o filtro de mídia.")
            XCTAssertEqual(viewModel.apodList.first?.title, "Image 3", "O primeiro item deve ser o mais recente.")
            XCTAssertEqual(viewModel.apodList.last?.title, "Image 1", "O último item deve ser o mais antigo.")
            XCTAssertFalse(viewModel.apodList.contains(where: { $0.mediaType == "video" }), "Nenhum vídeo deve estar na lista.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testFetchAPODListFailure() throws {
        let expectation = XCTestExpectation(description: "Carregar lista de APODs falha")
        
        class MockAPODServiceFailure: APODServiceProtocol {
            func fetchAPOD(for date: Date?) -> AnyPublisher<APODModel, TypeError> {
                return Fail(error: TypeError.networkError(NSError(domain: "test", code: -1))).eraseToAnyPublisher()
            }
            func fetchAPODRange(startDate: Date, endDate: Date) -> AnyPublisher<[APODModel], TypeError> {
                return Fail(error: TypeError.networkError(NSError(domain: "test", code: -1))).eraseToAnyPublisher()
            }
        }
        
        let viewModel = ListViewModel(apodService: MockAPODServiceFailure(), favoritesService: MockFavoritesService())
        
        viewModel.fetchAPODList()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.errorMessage)
            XCTAssertTrue(viewModel.apodList.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testAddsToFavorites() throws {
        let expectation = XCTestExpectation(description: "Toggle favorito adiciona item")
        let mockFavoritesService = MockFavoritesService()
        let viewModel = ListViewModel(apodService: MockAPODService(), favoritesService: mockFavoritesService)
        
        let apod = APODModel(date: "2024-01-04", explanation: "", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        viewModel.apodList = [apod]
        
        XCTAssertFalse(viewModel.isFavorite(apod), "Item não deve ser favorito no início.")
        
        viewModel.toggleFavorite(for: apod)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(viewModel.isFavorite(apod), "Item deve se tornar favorito após o toggle.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
}
