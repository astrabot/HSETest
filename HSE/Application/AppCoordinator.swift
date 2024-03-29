//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation
import UIKit

class AppCoordinator {
    let navigationController: UINavigationController
    lazy var apiService: APIServiceType = {
        let configuration = URLSessionConfiguration.default // or URLSessionConfiguration.ephemeral to do not use persistent storage for caches, cookies, or credentials
        configuration.timeoutIntervalForRequest = 5 // make request timeout shorter
        let session = URLSession(configuration: configuration)
        return APIService(provider: session, decoder: JSONDecoder())
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = HomeViewModel(title: Strings.homeScreenTitle, api: apiService)
        viewModel.onSelectCategory = { [weak self] category in
            self?.selectCategory(category)
        }
        // a. Constructor injection of a view model
        let homeViewController = HomeViewController(viewModel: viewModel)
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
        // b. Property injection of a view model
        categoryViewController.viewModel = viewModel
        navigationController.pushViewController(categoryViewController, animated: true)
    }

    func selectProduct(_ product: ProductHit) {
        let productViewController = ProductViewController()
        productViewController.viewModel = ProductViewModel(product: product, api: apiService)
        navigationController.pushViewController(productViewController, animated: true)
    }
}
