//
//  ImageLoaderTests.swift
//  PictureDayTests
//
//  Created by Kleyson Tavares on 19/09/25.
//

import Combine
import XCTest
@testable import PictureDay

final class ImageLoaderTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var sut: ImageLoader!
    private var session: URLSession!
    
    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        sut = ImageLoader(session: session)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        sut = nil
        session = nil
        MockURLProtocol.requestHandler = nil
    }

    func testLoadImageSuccess() throws {
        let expectation = XCTestExpectation(description: "Carregar imagem com sucesso")
        
        let mockImage = UIImage(systemName: "photo")!
        let mockData = mockImage.jpegData(compressionQuality: 1.0)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        sut.loadImage(from: "https://mock.url/image.jpg")
        
        sut.$image
            .dropFirst()
            .sink { image in
                XCTAssertNotNil(image)
                XCTAssertTrue(self.sut.isLoading)
                XCTAssertNil(self.sut.error)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }

    func testNetworkError() throws {
        let expectation = XCTestExpectation(description: "Erro de rede")
        
        let mockError = NSError(domain: "NetworkError", code: -1, userInfo: nil)
        MockURLProtocol.requestHandler = { request in
            throw mockError
        }
        
        sut.loadImage(from: "https://mock.url/image.jpg")
        
        sut.$error
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(error?.localizedDescription, "The operation couldn’t be completed. (NSURLErrorDomain error -1.)")
                XCTAssertFalse(self.sut.isLoading)
                XCTAssertNil(self.sut.image)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.2)
    }
}
