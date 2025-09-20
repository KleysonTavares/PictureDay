//
//  FavoritesServiceTests.swift
//  FavoritesServiceTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import Combine
import CoreData
import XCTest
@testable import PictureDay

final class FavoritesServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var sut: FavoritesService!
    private var container: NSPersistentContainer!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()

        container = NSPersistentContainer(name: "PictureDay")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        sut = FavoritesService(context: container.viewContext)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        sut = nil
        container = nil
    }

    // MARK: - FavoritesService Tests

    func testAddToFavoriteSuccess() throws {
        let expectation = XCTestExpectation(description: "Add to favorites successfully")
        
        let apod = APODModel(date: "2024-01-01", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")

        sut.addToFavorites(apod)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { success in
                XCTAssertTrue(success, "Deveria ter adicionado aos favoritos com sucesso")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.2)
    }
    
    func testAddToFavoritesAlreadyExists() throws {
        let expectation = XCTestExpectation(description: "Adding an existing item should fail")
        
        let apod = APODModel(date: "2024-01-02", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")

        sut.addToFavorites(apod).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sut.addToFavorites(apod)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, but got error: \(error)")
                    }
                    expectation.fulfill()
                }, receiveValue: { success in
                    XCTAssertFalse(success, "Deveria ter falhado ao adicionar item que já existe")
                })
                .store(in: &self.cancellables)
        }

        wait(for: [expectation], timeout: 0.2)
    }

    func testRemoveFromFavoriteSuccess() throws {
        let expectation = XCTestExpectation(description: "Remove from favorites successfully")
        
        let apod = APODModel(date: "2024-01-03", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")

        let addExpectation = XCTestExpectation(description: "Add item before removal")
        sut.addToFavorites(apod).sink(receiveCompletion: { _ in addExpectation.fulfill() }, receiveValue: { _ in }).store(in: &cancellables)
        wait(for: [addExpectation], timeout: 0.2)

        sut.removeFromFavorites(apod)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but got error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { success in
                XCTAssertTrue(success, "Deveria ter removido dos favoritos com sucesso")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.2)
    }

    func testItemExist() throws {
        let expectation = XCTestExpectation(description: "Check if favorite returns true")
        
        let apod = APODModel(date: "2024-01-04", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        sut.addToFavorites(apod).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)

        sut.isFavorite(apod)
            .sink(receiveCompletion: { _ in }, receiveValue: { isFav in
                XCTAssertTrue(isFav, "O item deveria ser favorito")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.2)
    }

    func testtemDoesNotExist() throws {
        let expectation = XCTestExpectation(description: "Check if favorite returns false")
        
        let apod = APODModel(date: "2024-01-05", explanation: "Exp", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test", url: "url")
        
        sut.isFavorite(apod)
            .sink(receiveCompletion: { _ in }, receiveValue: { isFav in
                XCTAssertFalse(isFav, "O item não deveria ser favorito")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.2)
    }

    func testReturnsItemsInCorrectOrder() throws {
        let expectation = XCTestExpectation(description: "Fetch favorites returns items correctly sorted")

        let apod1 = APODModel(date: "2024-01-01", explanation: "Exp1", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test1", url: "url1")
        let apod2 = APODModel(date: "2024-01-02", explanation: "Exp2", hdurl: nil, mediaType: "image", serviceVersion: "v1", title: "Test2", url: "url2")
        
        sut.addToFavorites(apod1).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sut.addToFavorites(apod2).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &self.cancellables)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sut.fetchFavorites()
                .sink(receiveCompletion: { _ in }, receiveValue: { favorites in
                    XCTAssertEqual(favorites.count, 2)
                    XCTAssertEqual(favorites.first?.title, "Test2", "O item mais recente deve vir primeiro")
                    XCTAssertEqual(favorites.last?.title, "Test1", "O item mais antigo deve vir por último")
                    expectation.fulfill()
                })
                .store(in: &self.cancellables)
        }

        wait(for: [expectation], timeout: 0.2)
    }
}
