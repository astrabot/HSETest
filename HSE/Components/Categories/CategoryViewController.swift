//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

final class CategoryViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    var viewModel: CategoryViewModelType? {
        didSet { bind(to: viewModel) }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = CategoryViewLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ProductCell.self)
        collectionView.register(CategoriesCarouselHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.register(LoadingFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
        return collectionView
    }()

    private enum Constants {
        static let headerHeight: CGFloat = 56
        static let visibleFooterHeight: CGFloat = 56
        static let hiddenFooterHeight: CGFloat = 0
    }

    private var loadingFooterHeight: CGFloat = Constants.hiddenFooterHeight

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startInitialFetching()
    }

    private func bind(to viewModel: CategoryViewModelType?) {
        cancellables.removeAll()
        guard let viewModel = viewModel else { return }

        viewModel.titlePublisher.receive(on: DispatchQueue.main).assign(to: \.title, on: self).store(in: &cancellables)
        viewModel.statePublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .initial: break
            case .loading:
                self.setFooterVisible(true)
            case .loaded:
                self.collectionView.reloadData()
                self.setFooterVisible(false)
                self.updateTitle()
            case .fail(let error):
                self.setFooterVisible(false)
                self.showError(error)
            }
        }.store(in: &cancellables)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel else { return }
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        updateTitle()

        if distanceFromBottom < height, viewModel.state != .loading, viewModel.hasMoreProductsToDisplay {
            viewModel.fetchMoreSearchResults()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitle()
    }

    // MARK: - Helpers

    private func setFooterVisible(_ isVisible: Bool) {
        loadingFooterHeight = isVisible ? Constants.visibleFooterHeight : Constants.hiddenFooterHeight
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func showError(_ error: Error) {
        let alertController = UIAlertController(title: Strings.errorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Strings.errorAlertOK, style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }

    private func updateTitle() {
        viewModel?.updateTitleForVisibleItems(collectionView.indexPathsForVisibleItems)
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.products.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(for: indexPath) as ProductCell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ProductCell else { return }
        guard let product = viewModel?.products[indexPath.item] else { return }
        cell.configure(with: product)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath) as CategoriesCarouselHeaderView
            headerView.viewModel = viewModel?.makeCategoriesCarouselViewModel()
            return headerView
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath) as LoadingFooterView
        default:
            assertionFailure("Unsupported supplementary element of kind " + kind)
            return UICollectionReusableView()
        }
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerHeight = (viewModel?.hasSubcategories ?? false) ? Constants.headerHeight : 0
        return CGSize(width: view.frame.size.width, height: headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: view.frame.size.width, height: loadingFooterHeight)
    }
}
