//
//  Created by Aliaksandr Strakovich on 13.02.22.
//

import Combine
import XCTest
@testable import HSETest

final class APINetworkTests: XCTestCase {
    var apiService: APIServiceType!
    private var cancellables: [AnyCancellable] = []

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        let urlSession = URLSession(configuration: configuration)
        apiService = APIService(provider: urlSession, decoder: JSONDecoder())
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
        apiService = nil
    }

    func test_fetchTopCategories() throws {
        let expectation = self.expectation(description: #function)
        apiService.categories()
        .sink { result in
            switch result {
            case .failure(let error): XCTFail("\(error)")
            case .finished: break
            }
        } receiveValue: { container in
            XCTAssertEqual(container.categories.count, 7, "invalid number of categories")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_searchByCategory() {
        let expectation = self.expectation(description: #function)
        apiService.search(path: "Kochen", query: "Topf", page: SearchPaging(number: 1, hitsPerPage: 11))
        .sink { result in
            switch result {
            case .failure(let error): XCTFail("\(error)")
            case .finished: break
            }
        } receiveValue: { searchResult in
            XCTAssertFalse(searchResult.hits.isEmpty, "something must be found")
            XCTAssertEqual(searchResult.paging?.hitsPerPage ?? 0, 11, "page size must be equal to requested")
            expectation.fulfill()
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
