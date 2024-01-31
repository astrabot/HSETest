//
//  Created by Aliaksandr Strakovich on 13.02.22.
//

import Combine
@testable import HSETest
import Foundation

class APIProviderMock: APIProviderType {
    var mockedDataPublisher: AnyPublisher<APIResponse, URLError>!
    func dataPublisher(for request: URLRequest) -> AnyPublisher<APIResponse, URLError> {
        mockedDataPublisher
    }
}
