//
//  UITapGestureRecognizer+LabelLinks.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

extension UIGestureRecognizer {
    //Returns a character that was touched, or nil if none.
    func indexOfCharacterTouched(label: UILabel) -> Int? {
        let locationOfTouchInLabel = self.location(in: label)
        
        return label.indexOfCharacter(atPoint: locationOfTouchInLabel)
    }
}

public extension UILabel {
    public func indexOfCharacter(atPoint point: CGPoint) -> Int? {
        if self.attributedText == nil {
            return nil
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.size = self.bounds.size
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        if !textBoundingBox.contains(point) {
            return nil
        }
        
        let textContainerOffset = CGPoint(
            x: (self.bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (self.bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(
            x: point.x - textContainerOffset.x,
            y: point.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil)
        
        return indexOfCharacter
    }
}
