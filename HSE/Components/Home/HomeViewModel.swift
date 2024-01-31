//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

protocol HomeViewModelType {
    var statePublisher: AnyPublisher<HomeViewModel.State, Never> { get }
    var titlePublisher: AnyPublisher<String?, Never> { get }
    var numberOfCategories: Int { get }
    func startInitialFetching()
    func cellViewModel(at indexPath: IndexPath) -> HomeCellViewModel?
    func selectCategory(at indexPath: IndexPath)
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

    // To demonstrate that we can define all UI content via view models
    @Published var title: String?
    var titlePublisher: AnyPublisher<String?, Never> { $title.eraseToAnyPublisher() }

    private var categories: [CategoryModel]? {
        guard case let .loaded(categories) = state else { return nil }
        return categories
    }

    private let api: APIServiceType
    private var fetchCancellation: AnyCancellable?

    init(title: String?, api: APIServiceType) {
        self.api = api
        self.title = title
    }

    // Fetch categories
    func startInitialFetching() {
        if state != .initial { return } // avoid multiple calls e.g. while view is appearing
        state = .loading
        fetchCancellation = api.categories()
            //.delay(for: 0.5, scheduler: RunLoop.main) // just to show loading spinner :)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    self.state = .fail(error)
                }
            }, receiveValue: { container in
                let categories: [CategoryModel] = container.categories.map { CategoryModelBuilder().buildModel(for: $0) }
                self.state = .loaded(categories)
            })
    }

    var numberOfCategories: Int { categories?.count ?? 0 }

    func cellViewModel(at indexPath: IndexPath) -> HomeCellViewModel? {
        guard let category = categories?[indexPath.row] else { return nil }
        let titleText = category.displayName
        let detailText: String?
        let accessoryType: UITableViewCell.AccessoryType
        if category.children.isEmpty {
            detailText = nil
            accessoryType = .none
        } else {
            detailText = "Subcategories : \(category.children.count)"
            accessoryType = .disclosureIndicator
        }
        return HomeCellViewModel(titleText: titleText, detailText: detailText, accessoryType: accessoryType)
    }

    func selectCategory(at indexPath: IndexPath) {
        guard let category = categories?[indexPath.row] else { return }
        onSelectCategory?(category)
    }
}
