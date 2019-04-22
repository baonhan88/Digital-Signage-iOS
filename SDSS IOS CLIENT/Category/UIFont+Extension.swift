//
//  UIFont+Extension.swift
//  SDSS IOS CLIENT
//
//  Created by Nhan on 29/05/2017.
//  Copyright © 2017 SLab. All rights reserved.
//

import UIKit

extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        if descriptor != nil {
            return UIFont(descriptor: descriptor!, size: 0)
        }
        return self
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
