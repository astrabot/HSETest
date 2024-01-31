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
        case status = "Status"
        case regularPrice = "ReferencePrice"
        case specialPrice = "Price"
        case description = "variantValues"
        case imageURL = "ImageURL"
        case variantId = "ProductNumber"
    }
    let status: String
    let regularPrice: Double?
    let specialPrice: Double?
    let description: String?
    let imageURL: String?
    let variantId: String
}

struct Product: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case productId = "MasterProductNumber"
        case name = "Name"
        case description = "ShortDescription"
        case brand = "Brand"
    }
    let productId: String
    let name: String?
    let description: String?
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
    let base: Product
    let variants: [Variant]
    let position: Int
}

struct SearchResult: Decodable, Equatable {
    let paging: Paging?
    let totalHits: Int
    let hits: [ProductHit]
}
