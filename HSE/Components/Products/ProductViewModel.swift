//
//  Created by Aliaksandr Strakovich on 15.02.22.
//

import UIKit

protocol ProductViewModelType {
    var title: String? { get }
    var name: String? { get }
    var description: String? { get }
    var imageURL: URL? { get }
    var numberOfVariants: Int { get }
    func getVariant(at indexPath: IndexPath) -> Variant?
}

final class ProductViewModel: ProductViewModelType {
    lazy var title: String? = product.id
    lazy var name: String? = product.base.name
    lazy var description: String? = product.base.description
    lazy var imageURL: URL? = {
        variants.first?.imageURL.flatMap {
            AppConstants.baseProductImageURL.appendingPathComponent($0.appending(AppConstants.picsSuffixLarge))
        }
    }()

    var numberOfVariants: Int { variants.count }
    private var variants: [Variant] { product.variants } // convenience

    private let product: ProductHit
    private let api: APIServiceType

    init(product: ProductHit, api: APIServiceType) {
        self.product = product
        self.api = api
    }

    func getVariant(at indexPath: IndexPath) -> Variant? {
        guard indexPath.item < variants.count else { return nil } // check out of bounds
        return variants[indexPath.item]
    }
}
