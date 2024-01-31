//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

protocol CategoryViewModelType {
    var state: CategoryViewModel.State { get }
    var products: [ProductHit] { get }
    var hasMoreProductsToDisplay: Bool { get }
    var hasSubcategories: Bool { get }
    var titlePublisher: AnyPublisher<String?, Never> { get }
    var statePublisher: AnyPublisher<CategoryViewModel.State, Never> { get }
    var searchInput: CurrentValueSubject<String, Never> { get }
    func makeCategoriesCarouselViewModel() -> CategoriesCarouselViewModelType
    func updateTitleForVisibleItems(_ indexPaths: [IndexPath])
    func startInitialFetching()
    func fetchMoreSearchResults()
    func selectCategory(_ category: CategoryModel)
    func selectProduct(_ product: ProductHit)
}

final class CategoryViewModel: CategoryViewModelType {
    var onSelectCategory: ((CategoryModel) -> Void)?
    var onSelectProduct: ((ProductHit) -> Void)?

    let category: CategoryModel

    enum State: Equatable {
        case initial, loading, loaded(SearchResult), fail(APIError)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial),
                 (.loading, .loading): return true
            case (.loaded(let r1), .loaded(let r2)):
                return r1 == r2
            case (.fail(let e1), .fail(let e2)):
                return e1 == e2
            default: return false
            }
        }
    }

    @Published var state: State = .initial
    var statePublisher: AnyPublisher<CategoryViewModel.State, Never> { $state.eraseToAnyPublisher() }

    @Published var title: String?
    var titlePublisher: AnyPublisher<String?, Never> { $title.removeDuplicates().eraseToAnyPublisher() }

    var searchInput = CurrentValueSubject<String, Never>("") // search input (not implemented)
    private var cancellables: Set<AnyCancellable> = []

    private var currentVisiblePage = -1 // current visible page while scrolling. -1 means initial state
    private var productsPerPage = [Int: [ProductHit]]()
    var products: [ProductHit] {
        productsPerPage.sorted { $0.key < $1.key }.flatMap { $0.value }
    }

    var hasMoreProductsToDisplay: Bool {
        guard case let .loaded(result) = state, let paging = result.paging else { return false }
        return paging.currentPage < paging.pageCount
    }

    var hasSubcategories: Bool {
        !category.children.isEmpty
    }

    private let api: APIServiceType
    private var fetchCancellation: AnyCancellable?

    init(category: CategoryModel, api: APIServiceType) {
        self.category = category
        self.api = api
        self.title = category.displayName
    }

    func makeCategoriesCarouselViewModel() -> CategoriesCarouselViewModelType {
        let viewModel = CategoriesCarouselViewModel(categories: category.children)
        viewModel.onSelectCategory = { [weak self] category in
            self?.onSelectCategory?(category)
        }
        return viewModel
    }

    func updateTitleForVisibleItems(_ indexPaths: [IndexPath]) {
        guard case let .loaded(result) = state, let paging = result.paging else { return }
        let hitsPerPage = paging.hitsPerPage > 0 ? paging.hitsPerPage : 1
        let maxVisibleItem = indexPaths.map { $0.item }.max() ?? 1
        let currentVisiblePage = Int(maxVisibleItem / hitsPerPage) + 1
        if self.currentVisiblePage != currentVisiblePage {
            self.currentVisiblePage = currentVisiblePage
            title = category.displayName + " \(currentVisiblePage) of \(paging.pageCount)"
        }
    }

    func startInitialFetching() {
        if state != .initial { return } // avoid multiple calls e.g. while view is appearing
        search(query: searchInput.value, page: nil)
    }

    func fetchMoreSearchResults() {
        guard case let .loaded(result) = state, let paging = result.paging else { return }
        search(query: searchInput.value, page: SearchPaging(number: paging.currentPage + 1, hitsPerPage: nil))
    }

    private func search(query: String, page: SearchPaging?) {
        state = .loading
        fetchCancellation?.cancel()
        fetchCancellation = api.search(path: category.path, query: query.isEmpty ? "*" : query, page: page)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    print(error)
                    self.state = .fail(error)
                }
            }, receiveValue: { result in
                print("Did fetch search result: page \(result.paging?.currentPage ?? 1) | " +
                      "hits per page \(result.hits.count) | " +
                      "total hits \(result.totalHits) | " +
                      "total pages \(result.paging?.pageCount ?? 1)")
                self.state = .loaded(result)
                let currentPage = result.paging?.currentPage ?? 1 // page numbering begins from 1
                self.productsPerPage[currentPage] = result.hits
            })
    }

    func selectCategory(_ category: CategoryModel) {
        onSelectCategory?(category)
    }

    func selectProduct(_ product: ProductHit) {
        onSelectProduct?(product)
    }
}
