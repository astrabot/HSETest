//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Combine
import UIKit

class CategoryViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    var viewModel: CategoryViewModelType? {
        didSet { bind(to: viewModel) }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = HomeCollectionViewLayout()
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
        collectionView.register(LoadingFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
        return collectionView
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .systemOrange
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        return spinner
    }()

    private enum Constants {
        static let visibleFooterHeight: CGFloat = 56
        static let hiddenFooterHeight: CGFloat = 0
    }

    private var loadingFooterHeight: CGFloat = Constants.hiddenFooterHeight

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.startSearch()
    }

    private func setupNavigationItem() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
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
                self.collectionView.reloadData()
                self.setFooterVisible(true)
            case .loaded, .fail:
                self.collectionView.reloadData()
                self.setFooterVisible(false)
            }
            self.spinner.stopAnimating()
        }.store(in: &cancellables)
    }

    private func setFooterVisible(_ isVisible: Bool) {
        loadingFooterHeight = isVisible ? Constants.visibleFooterHeight : Constants.hiddenFooterHeight
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel else { return }
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        if distanceFromBottom < height, viewModel.state != .loading, viewModel.hasMoreProductsToDisplay {
            viewModel.loadMoreSearchResults()
        }
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.products.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCell = collectionView.dequeueReusableCell(for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ProductCell else { return }
        guard let product = viewModel?.products[indexPath.item] else { return }
        cell.configure(with: product)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath) as LoadingFooterView
        } else {
            assertionFailure("Unsupported supplementary element of kind " + kind)
            return UICollectionReusableView()
        }
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Display product details
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProductCell else { return }
        cell.setHighlighted(true)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProductCell else { return }
        cell.setHighlighted(false)
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: view.frame.size.width, height: loadingFooterHeight)
    }
}
