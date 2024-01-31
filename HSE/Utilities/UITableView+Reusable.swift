//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import UIKit

extension UITableViewCell: Reusable { }
extension UITableViewHeaderFooterView: Reusable { }

extension UITableView {
    // MARK: - Register

    final func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    final func register<T: UITableViewCell>(_: T.Type) where T: NibLoadable {
        register(T.nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    final func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }

    final func register<T: UITableViewHeaderFooterView>(_: T.Type) where T: NibLoadable {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }

    // MARK: - Dequeue

    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue a cell with identifier \(T.defaultReuseIdentifier)")
        }
        return cell
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
            fatalError("Could not dequeue a header/footer view with identifier: \(T.defaultReuseIdentifier)")
        }
        return headerFooter
    }
}
