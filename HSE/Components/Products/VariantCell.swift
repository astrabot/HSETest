//
//  Created by Aliaksandr Strakovich on 15.02.22.
//

import UIKit

private let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.currencyCode = "EUR"
    formatter.currencyDecimalSeparator = ","
    formatter.currencyGroupingSeparator = "."
    formatter.positiveFormat = "#,##0.00 ¤"
    return formatter
}()

final class VariantCell: UICollectionViewCell {
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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .darkText
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
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
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
    }

    func configure(with variant: Variant) {
        titleLabel.text = variant.regularPrice.flatMap { priceFormatter.string(from: NSDecimalNumber(value: $0)) }
        imageView.kf.indicatorType = .activity
        variant.imageURL.flatMap {
            let url = AppConstants.baseProductImageURL.appendingPathComponent($0.appending(AppConstants.picsSuffixSmall))
            imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))]) { [weak imageView] result in
                if case .failure = result {
                    imageView?.image = UIImage(systemName: Images.System.exclamationmark)?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
    }
}
