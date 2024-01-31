//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation

struct CategoriesContainer: Decodable {
    let categories: [Category]
}

struct Category: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case displayName = "display_name", children
    }

    let displayName: String
    let children: [Category]?
}

// Use class because value types cannot have a stored property that recursively contains it
class CategoryModel: Equatable {
    let displayName: String
    let children: [CategoryModel]
    weak var parent: CategoryModel?

    init(displayName: String, children: [CategoryModel] = []) {
        self.displayName = displayName
        self.children = children
        for child in self.children { child.parent = self }
    }

    var path: String {
        getPath().map { $0.displayName }.reversed().joined(separator: "/")
    }

    func getPath() -> [CategoryModel] {
        guard let parent = parent else { return [self] }
        return [self] + parent.getPath()
    }

    public static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.displayName == rhs.displayName
    }
}

struct CategoryModelBuilder {
    func buildModel(for category: Category) -> CategoryModel {
        let children: [Category] = category.children ?? []
        return CategoryModel(displayName: category.displayName, children: children.map { buildModel(for: $0) })
    }
}
