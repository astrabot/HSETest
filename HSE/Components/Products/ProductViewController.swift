//
//  Created by Aliaksandr Strakovich on 15.02.22.
//

import UIKit

final class ProductViewController: UIViewController {
    var viewModel: ProductViewModelType? {
        didSet {
            if isViewLoaded {
                bind(to: viewModel)
            }
        }
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(VariantCell.self)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(collectionView)

        let margin: CGFloat = 16

        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: margin),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -margin),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: margin),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: margin),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -margin),

            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: margin),
            collectionView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100),

            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: margin)
        ])

        bind(to: viewModel)
    }

    private func bind(to viewModel: ProductViewModelType?) {
        title = viewModel?.title
        titleLabel.text = viewModel?.name
        descriptionLabel.text = viewModel?.description
        imageView.kf.indicatorType = .activity
        if let imageURL = viewModel?.imageURL {
            imageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.3))])
        }
        collectionView.reloadData()
    }
}

extension ProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfVariants ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as VariantCell
        if let variant = viewModel?.getVariant(at: indexPath) {
            cell.configure(with: variant)
        }
        return cell
    }
}
