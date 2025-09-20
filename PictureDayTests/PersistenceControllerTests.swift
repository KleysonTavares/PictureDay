//
//  PersistenceControllerTests.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import XCTest
import CoreData
@testable import PictureDay

final class PersistenceControllerTests: XCTestCase {

    func testMemoryStore() throws {
        let expectation = XCTestExpectation(description: "Store loading completion handler")
        
        let controller = PersistenceController(inMemory: true)
        
        XCTAssertEqual(controller.container.persistentStoreDescriptions.first?.url, URL(fileURLWithPath: "/dev/null"))
        
        let context = controller.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                let count = try context.count(for: fetchRequest)
                XCTAssertEqual(count, 0)
                expectation.fulfill()
            } catch {
                XCTFail("Erro ao buscar dados: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testMergesChangesFromParent() throws {
        let controller = PersistenceController(inMemory: true)
        XCTAssertTrue(controller.container.viewContext.automaticallyMergesChangesFromParent)
    }

    @MainActor
    func testCreatesInMemoryStore() throws {
        let controller = PersistenceController.preview
        XCTAssertEqual(controller.container.persistentStoreDescriptions.first?.url, URL(fileURLWithPath: "/dev/null"))
    }

    @MainActor
    func testAddsItems() throws {
        let expectation = XCTestExpectation(description: "Preview data is loaded and items are counted")
        
        let controller = PersistenceController.preview
        let context = controller.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            do {
                let count = try context.count(for: fetchRequest)
                XCTAssertEqual(count, 10)
                expectation.fulfill()
            } catch {
                XCTFail("Erro ao buscar dados de pré-visualização: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 0.2)
    }
}
