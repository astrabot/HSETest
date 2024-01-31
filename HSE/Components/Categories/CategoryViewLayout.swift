//
//  Created by Aliaksandr Strakovich on 12.02.22.
//

import UIKit

final class CategoryViewLayout: UICollectionViewFlowLayout {
    var numberOfColumns = UIScreen.main.nativeBounds.width > 1668 ? 3 : 2

    private enum Constants {
        static let gridTitleAndSubtitleHeight = CGFloat(74)
    }

    override func prepare() {
        defer { super.prepare() }
        prepareGridLayout()
    }

    private func prepareGridLayout() {
        scrollDirection = .vertical
        minimumInteritemSpacing = 10
        minimumLineSpacing = 20
        sectionInset = UIEdgeInsets(top: minimumLineSpacing, left: 14, bottom: minimumLineSpacing, right: 14)
        guard let collectionView = collectionView else { return }
        itemSize = sizeForGridItem(in: collectionView)
    }

    private func sizeForGridItem(in collectionView: UICollectionView) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfInteritemSpaces = numberOfColumns - 1
        let availableWidth = width - (sectionInset.left + sectionInset.right + CGFloat(numberOfInteritemSpaces) * minimumInteritemSpacing)
        let itemWidth = floor(availableWidth / CGFloat(numberOfColumns))
        let imageAspectRatio = 2.5
        let itemHeight = floor(itemWidth / imageAspectRatio) + Constants.gridTitleAndSubtitleHeight
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
