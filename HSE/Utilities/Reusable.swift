//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import Foundation

protocol Reusable: AnyObject {
    /// The default reuse identifier
    static var defaultReuseIdentifier: String { get }
}

extension Reusable {
    /// Use the class name as its reuse identifier
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
