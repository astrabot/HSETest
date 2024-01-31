//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation
import UIKit

class AppCoordinator {
    let navigationController: UINavigationController
    lazy var apiService = APIService(provider: URLSession.shared, decoder: JSONDecoder())

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeViewController = HomeViewController()
        let viewModel = HomeViewModel(title: Strings.homeScreenTitle, api: apiService)
        viewModel.onSelectCategory = { [weak self] category in
            self?.selectCategory(category)
        }
        homeViewController.viewModel = viewModel
        navigationController.pushViewController(homeViewController, animated: true)
    }

    func selectCategory(_ category: CategoryModel) {
        let categoryViewController = CategoryViewController()
        let viewModel = CategoryViewModel(category: category, api: apiService)
        viewModel.onSelectCategory = { [weak self] subcategory in
            self?.selectCategory(subcategory)
        }
        viewModel.onSelectProduct = { [weak self] product in
            self?.selectProduct(product)
        }
        categoryViewController.viewModel = viewModel
        navigationController.pushViewController(categoryViewController, animated: true)
    }

    func selectProduct(_ product: ProductHit) {
        let productViewController = ProductViewController()
        productViewController.viewModel = ProductViewModel(product: product, api: apiService)
        navigationController.pushViewController(productViewController, animated: true)
    }
}
