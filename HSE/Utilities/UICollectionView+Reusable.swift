//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import UIKit

extension UICollectionReusableView: Reusable { }

extension UICollectionView {
    // MARK: - Register

    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    func register<T: UICollectionViewCell>(_: T.Type) where T: NibLoadable {
        register(T.nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    func register<T: UICollectionReusableView>(_: T.Type, ofKind elementKind: String) {
        register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionReusableView>(_: T.Type, ofKind elementKind: String) where T: NibLoadable {
        register(T.nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    // MARK: - Dequeue

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue a cell with identifier \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue a supplementary view with identifier \(T.defaultReuseIdentifier)")
        }
        return view
    }
}
