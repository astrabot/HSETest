//
//  Created by Aliaksandr Strakovich on 12.02.22.
//

import Combine
import UIKit

private final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        for attribute in attributes {
            if attribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing
            maxY = max(attribute.frame.maxY, maxY)
        }
        return attributes
    }
}

final class CategoriesCarouselHeaderView: UICollectionReusableView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var cancellables: Set<AnyCancellable> = []
    var viewModel: CategoriesCarouselViewModelType? {
        didSet { bind(to: viewModel) }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CategoryCarouselCell.self)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        backgroundColor = .yellow
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func bind(to viewModel: CategoriesCarouselViewModelType?) {
        cancellables.removeAll()
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        viewModel.didSelectCategory(viewModel.getCategory(at: indexPath.item))
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15) {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.1) {
            cell.transform = .identity
        }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfCategories ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCarouselCell = collectionView.dequeueReusableCell(for: indexPath)
        configure(cell, forItemAt: indexPath)
        return cell
    }

    private func configure(_ cell: CategoryCarouselCell, forItemAt indexPath: IndexPath) {
        guard let category = viewModel?.getCategory(at: indexPath.item) else { return }
        cell.configure(with: category)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let category = viewModel?.getCategory(at: indexPath.item) else { return .zero }
        let labelSize = category.displayName.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .callout)])
        return CGSize(width: labelSize.width + 8, height: collectionView.bounds.height)
    }
}
