//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation

struct Paging: Decodable, Equatable {
    let currentPage: Int
    let pageCount: Int
    let hitsPerPage: Int // page size
    let defaultHitsPerPage: Int
}

struct Variant: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case sku = "ProductNumber"
        case status = "Status"
        case regularPrice = "ReferencePrice"
        case specialPrice = "Price"
        case description = "variantValues"
        case imageUrl = "ImageURL"
    }
    let sku: String
    let status: String
    let regularPrice: Double?
    let specialPrice: Double?
    let description: String?
    let imageUrl: String?
}

struct BaseProduct: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case sku = "MasterProductNumber"
        case name = "Name"
        case description = "Description"
        case shortDescription = "ShortDescription"
        case brand = "Brand"
    }
    let sku: String
    let name: String?
    let description: String?
    let shortDescription: String?
    let brand: String?
}

struct ProductHit: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id
        case base = "masterValues"
        case variants = "variantValues"
        case position
    }
    let id: String
    let base: BaseProduct
    let variants: [Variant]
    let position: Int

    /// Get main product image as the image of the first variant
    var imageUrl: String? {
        variants.first?.imageUrl
    }
}

struct SearchResult: Decodable, Equatable {
    let paging: Paging?
    let totalHits: Int
    let hits: [ProductHit]
}
