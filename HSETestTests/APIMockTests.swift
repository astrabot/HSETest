//
//  Created by Aliaksandr Strakovich on 13.02.22.
//

import Combine
import XCTest
@testable import HSETest

final class APIMockTests: XCTestCase {
    var apiService: APIServiceType!
    var apiProviderMock: APIProviderMock!
    private var cancellables: [AnyCancellable] = []

    override func setUpWithError() throws {
        apiProviderMock = APIProviderMock()
        apiService = APIService(provider: apiProviderMock, decoder: JSONDecoder())
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
        apiService = nil
        apiProviderMock = nil
    }

    func test_fetchTopCategories_emptyJSONBody() throws {
        let response = makeMockAPIResponse(with: "")
        let mockedDataPublisher = Just(response).setFailureType(to: URLError.self).eraseToAnyPublisher()
        apiProviderMock.mockedDataPublisher = mockedDataPublisher

        let expectation = self.expectation(description: #function)
        apiService.categories()
        .sink { result in
            switch result {
            case .failure(APIError.jsonDecodingError): break
            default: XCTFail("unexpected result")
            }
            expectation.fulfill()
        } receiveValue: { _ in }
        .store(in: &cancellables)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_fetchTopCategories_emptyList() throws {
        let response = makeMockAPIResponse(with: "{\"categories\":[]}")
        let mockedDataPublisher = Just(response).setFailureType(to: URLError.self).eraseToAnyPublisher()
        apiProviderMock.mockedDataPublisher = mockedDataPublisher

        let expectation = self.expectation(description: #function)
        apiService.categories()
        .sink { result in
            switch result {
            case .failure: XCTFail("unexpected error")
            case .finished: break
            }
        } receiveValue: { container in
            XCTAssertTrue(container.categories.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_fetchTopCategories_badServerResponse() throws {
        apiProviderMock.mockedDataPublisher = Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()

        let expectation = self.expectation(description: #function)
        apiService.categories()
        .sink { result in
            switch result {
            case .failure(APIError.networkError): break
            default: XCTFail("unexpected result")
            }
            expectation.fulfill()
        } receiveValue: { _ in }
        .store(in: &cancellables)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_searchByCategory_badServerResponse() {
        apiProviderMock.mockedDataPublisher = Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()

        let expectation = self.expectation(description: #function)
        apiService.search(path: "Kochen", query: "Topf", page: SearchPaging(number: 1, hitsPerPage: 11))
        .sink { result in
            switch result {
            case .failure(.networkError): break
            default: XCTFail("unexpected result")
            }
            expectation.fulfill()
        } receiveValue: { _ in }
        .store(in: &cancellables)
        waitForExpectations(timeout: 1, handler: nil)
    }

    private func makeMockAPIResponse(with string: String) -> (data: Data, response: URLResponse) {
        let response = HTTPURLResponse(url: URL(string: "https://dev.null")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let data = string.data(using: .utf8)!
        return (data, response as URLResponse)
    }
}
