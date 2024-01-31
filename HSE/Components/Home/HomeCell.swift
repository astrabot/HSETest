//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import UIKit

struct HomeCellViewModel {
    let titleText: String?
    let detailText: String?
    let accessoryType: UITableViewCell.AccessoryType
}

final class HomeCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        accessoryType = .none
    }

    func configure(with viewModel: HomeCellViewModel) {
        textLabel?.text = viewModel.titleText
        detailTextLabel?.text = viewModel.detailText
        accessoryType = viewModel.accessoryType
    }
}
