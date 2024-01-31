//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import UIKit

protocol NibLoadable: AnyObject {
    /// The nib file to use to load
    static var nib: UINib { get }
}

extension NibLoadable {
    /// By default, uses the nib with the name of the class
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}
