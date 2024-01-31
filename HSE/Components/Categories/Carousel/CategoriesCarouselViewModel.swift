//
//  Created by Aliaksandr Strakovich on 12.02.22.
//

import Foundation

protocol CategoriesCarouselViewModelType {
    var numberOfCategories: Int { get }
    func getCategory(at index: Int) -> CategoryModel
    func didSelectCategory(_ category: CategoryModel)
}

final class CategoriesCarouselViewModel: CategoriesCarouselViewModelType {
    let categories: [CategoryModel]
    var onSelectCategory: ((CategoryModel) -> Void)?

    var numberOfCategories: Int { categories.count }

    init(categories: [CategoryModel]) {
        self.categories = categories
    }

    func getCategory(at index: Int) -> CategoryModel {
        categories[index]
    }

    func didSelectCategory(_ category: CategoryModel) {
        onSelectCategory?(category)
    }
}
