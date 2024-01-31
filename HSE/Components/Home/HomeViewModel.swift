//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation
import Combine

protocol HomeViewModelType {
    var statePublisher: AnyPublisher<HomeViewModel.State, Never> { get }
    var titlePublisher: AnyPublisher<String?, Never> { get }
    var categories: [CategoryModel] { get }
    func fetchCategories(isInitial: Bool)
    func selectCategory(_ category: CategoryModel)
}

struct CategoryModelBuilder {
    func buildModel(for category: Category) -> CategoryModel {
        let children: [Category] = category.children ?? []
        return CategoryModel(displayName: category.displayName, children: children.map { buildModel(for: $0) })
    }
}

final class HomeViewModel: HomeViewModelType {
    var onSelectCategory: ((CategoryModel) -> Void)?

    enum State: Equatable {
        case initial, loading, loaded([CategoryModel]), fail(APIError)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial),
                 (.loading, .loading): return true
            case (.loaded(let c1), .loaded(let c2)):
                return c1 == c2
            case (.fail(let e1), .fail(let e2)):
                return e1 == e2
            default: return false
            }
        }
    }
    @Published var state: State = .initial
    var statePublisher: AnyPublisher<HomeViewModel.State, Never> { $state.eraseToAnyPublisher() }

    // To demonstrate that we can define all UI content view view models
    @Published var title: String?
    var titlePublisher: AnyPublisher<String?, Never> { $title.eraseToAnyPublisher() }

    var categories: [CategoryModel] {
        guard case let .loaded(categories) = state else { return [] }
        return categories
    }

    private let api: APIServiceType
    private var fetchCancellation: AnyCancellable?

    init(title: String?, api: APIServiceType) {
        self.api = api
        self.title = title
    }

    // Fetch categories. Use isInitial to avoid multiple calls while view is appearing
    func fetchCategories(isInitial: Bool) {
        if isInitial && state != .initial { return }
        state = .loading
        fetchCancellation?.cancel() // cancel previous request
        fetchCancellation = api.categories()
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    self.state = .fail(error)
                }
            }, receiveValue: { container in
                let categories: [CategoryModel] = container.categories.map { CategoryModelBuilder().buildModel(for: $0) }
                self.state = .loaded(categories)
            })
    }

    func selectCategory(_ category: CategoryModel) {
        onSelectCategory?(category)
    }
}
