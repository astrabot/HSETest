//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

protocol CategoryViewModelType {
    var titlePublisher: AnyPublisher<String?, Never> { get }
    var statePublisher: AnyPublisher<CategoryViewModel.State, Never> { get }
    var searchInput: CurrentValueSubject<String, Never> { get }
    var products: [ProductHit] { get }
    func searchProducts()
    func selectCategory(_ category: CategoryModel)
    func selectProduct(_ product: ProductHit)
}


final class CategoryViewModel: CategoryViewModelType {
    var onSelectCategory: ((CategoryModel) -> Void)?
    var onSelectProduct: ((ProductHit) -> Void)?

    let category: CategoryModel

    enum State {
        case initial, loading, loaded(SearchResult), fail(APIError)
    }

    @Published var state: State = .initial
    var statePublisher: AnyPublisher<CategoryViewModel.State, Never> { $state.eraseToAnyPublisher() }
    var titlePublisher: AnyPublisher<String?, Never>
    var searchInput = CurrentValueSubject<String, Never>("")
    private var cancellables: Set<AnyCancellable> = []

    var products: [ProductHit] {
        guard case let .loaded(result) = state else { return [] }
        return result.hits
    }

    private let api: APIServiceType
    private var fetchCancellation: AnyCancellable?

    init(category: CategoryModel, api: APIServiceType) {
        self.category = category
        self.api = api
        titlePublisher = CurrentValueSubject(category.path).eraseToAnyPublisher()
    }

    func searchProducts() {
        search(query: "")
    }

    private func search(query: String) {
        fetchCancellation?.cancel()
        fetchCancellation = api.search(path: category.path, matching: query.isEmpty ? "*" : query)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    self.state = .fail(error)
                }
            }, receiveValue: { result in
                self.state = .loaded(result)
            })
    }

    func selectCategory(_ category: CategoryModel) {
        onSelectCategory?(category)
    }

    func selectProduct(_ product: ProductHit) {
        onSelectProduct?(product)
    }
}
