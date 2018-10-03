//
//  NSMutableAttributedString+RemoveAttributes.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func removeAttributes() {
        let range = NSMakeRange(0, self.length)
        self.removeAttributes(range: range)
    }
    
    func removeAttributes(range: NSRange) {
        self.enumerateAttributes(
            in: range,
            options: []) {
                (attributes, range: NSRange, _) -> Void in
                
                for (attributeName, _) in attributes {
                    self.removeAttribute(attributeName, range: range)
                }
        }
    }
}
