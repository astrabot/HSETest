//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Kingfisher
import UIKit

final class ProductCell: UICollectionViewCell {
    private enum Constants {
        static let cornerRadius: CGFloat = 5
        static let borderColor: UIColor = .gray
        static let borderWidth: CGFloat = 1.0 / UIScreen.main.scale
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .label
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .label
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private lazy var containerView: UIView = {
        let effectsView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        effectsView.translatesAutoresizingMaskIntoConstraints = false
        effectsView.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: effectsView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: effectsView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: effectsView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: effectsView.layoutMarginsGuide.bottomAnchor)
        ])
        return effectsView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = nil
        contentView.backgroundColor = .tertiarySystemBackground

        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Constants.borderColor.cgColor
        contentView.layer.cornerRadius = Constants.cornerRadius

        contentView.addSubview(imageView)
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
    }

    func configure(with product: ProductHit) {
        titleLabel.text = product.base.name
        descriptionLabel.text = product.base.shortDescription
        guard let imageUrl = product.variants.first?.imageURL else {
            imageView.image = UIImage(systemName: Images.System.questionmark)?.withRenderingMode(.alwaysTemplate)
            return
        }
        let url = AppConstants.baseProductImageURL.appendingPathComponent(imageUrl.appending(AppConstants.picsSuffixSmall))
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))]) { [weak imageView] result in
            if case .failure = result {
                imageView?.image = UIImage(systemName: Images.System.exclamationmark)?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
