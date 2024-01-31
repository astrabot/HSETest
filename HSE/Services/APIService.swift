//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import Foundation

enum APIError: Error, Equatable {
    case unknown
    case networkError
    case jsonDecodingError
    case cannotBuildURL
}

enum ApiRoute {
    case categories
    case search

    var path: String {
        switch self {
        case .categories:
            return "/files/c/categories/de_DE/category-tree.json"
        case .search:
            return "/s/search/dede"
        }
    }
}

protocol APIServiceType {
    func categories() -> AnyPublisher<CategoriesContainer, APIError>
    func search(path: String, query: String, page: SearchPaging?) -> AnyPublisher<SearchResult, APIError>
}

extension APIServiceType {
    func search(path: String) -> AnyPublisher<SearchResult, APIError> { search(path: path, query: "*", page: nil) }
}

// Simple API service
final class APIService: APIServiceType {
    private let session: URLSession
    private let decoder: JSONDecoder

    let baseURL = URL(string: "https://www.hse.de/dpl")!

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    /// Returns a list of top categories.
    func categories() -> AnyPublisher<CategoriesContainer, APIError> {
        request(for: buildURL(for: .categories))
    }

    /// Returns a search result in the category.
    ///
    /// - Parameters:
    ///   - path: A full category path string.
    ///   - query: A search query string.
    ///   - page: Optional. A page of search results. No value means returning the first page with the default page size.
    func search(path: String, query: String, page: SearchPaging?) -> AnyPublisher<SearchResult, APIError> {
        print("Load path: '\(path)' | query: '\(query)' | page: \(page?.number ?? 1)")
        var components = URLComponents() // NOTE: URLComponents automatically encodes query items
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "filter", value: "CategoryPath:\(path)")
        ]
        if let page = page?.number {
            components.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        if let size = page?.hitsPerPage {
            components.queryItems?.append(URLQueryItem(name: "hitsPerPage", value: "\(size)"))
        }
        guard let url = components.url(relativeTo: buildURL(for: .search)) else {
            return Fail(error: .cannotBuildURL).eraseToAnyPublisher()
        }
        return request(for: url)
    }

    // MARK: - Helpers

    private func buildURL(for route: ApiRoute) -> URL {
        baseURL.appendingPathComponent(route.path)
    }

    private func request<T: Decodable>(for url: URL) -> AnyPublisher<T, APIError> {
        session.dataTaskPublisher(for: url)
            .tryMap {
                guard let httpResponse =  $0.response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return $0.data
            }
            .mapError { error -> APIError in
                print(error)
                return APIError.networkError
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                print(error)
                return APIError.jsonDecodingError
            }
            .eraseToAnyPublisher()
    }
}
