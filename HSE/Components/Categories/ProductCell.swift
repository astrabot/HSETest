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
        static let baseURL = URL(string: "https://pic.hse24-dach.net/media/de/products")!
        static let picsSuffix = "_pics480.jpg"
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .label
        label.numberOfLines = 2
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
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.layoutMarginsGuide.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
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
        descriptionLabel.text = product.base.description
        guard let imageUrl = product.variants.first?.imageURL else {
            imageView.image = UIImage(systemName: Images.System.questionmark)?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .gray
            return
        }
        let url = Constants.baseURL.appendingPathComponent(imageUrl.appending(Constants.picsSuffix))
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))]) { [weak imageView] result in
            if case .failure = result {
                DispatchQueue.main.async {
                    imageView?.image = UIImage(systemName: Images.System.exclamationmark)?.withRenderingMode(.alwaysTemplate)
                    imageView?.tintColor = .red
                }
            }
        }
    }

    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            contentView.backgroundColor = .lightGray
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        } else {
            contentView.backgroundColor = .tertiarySystemBackground
            titleLabel.textColor = .label
            descriptionLabel.textColor = .label
        }
    }
}
