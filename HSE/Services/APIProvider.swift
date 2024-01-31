//
//  Created by Aliaksandr Strakovich on 13.02.22.
//

import Combine
import Foundation

protocol APIProviderType {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func dataPublisher(for request: URLRequest) -> AnyPublisher<APIResponse, URLError>
}

extension URLSession: APIProviderType {
    func dataPublisher(for request: URLRequest) -> AnyPublisher<APIResponse, URLError> {
        return dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}
