//
//  LinkLabel.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


private class Attribute {
    let attributeName: String
    let value: AnyObject
    let range: NSRange
    
    init(attributeName: String, value: AnyObject, range: NSRange) {
        self.attributeName = attributeName
        self.value = value
        self.range = range
    }
}

private class LinkAttribute {
    let url: URL
    let range: NSRange
    
    init(url: URL, range: NSRange) {
        self.url = url
        self.range = range
    }
}

extension NSAttributedStringKey {
    // static NSAttributedStringKey
}

public protocol LinkLabelInteractionDelegate: class {
    func linkLabelDidSelectLink(linkLabel: LinkLabel, url: URL)
}

open class LinkLabel: UILabel, UIGestureRecognizerDelegate {
    
    fileprivate var linkAttributes: Array<LinkAttribute> = []
    
    fileprivate var standardTextAttributes: Array<Attribute> = []
    
    open var linkTextAttributes: Dictionary<NSAttributedStringKey, AnyObject> {
        didSet {
            self.setupAttributes()
        }
    }
    
    //Text attributes displayed when a link has been highlighted
    open var highlightedLinkTextAttributes: Dictionary<NSAttributedStringKey, AnyObject> {
        didSet {
            self.setupAttributes()
        }
    }
    
    fileprivate var highlightedLinkAttribute: LinkAttribute? {
        didSet {
            if self.highlightedLinkAttribute !== oldValue {
                self.setupAttributes()
            }
        }
    }
    
    override open var attributedText: NSAttributedString? {
        set {
            if newValue == nil {
                super.attributedText = newValue
                return
            }
            
            super.attributedText = newValue
            
            if newValue != nil {
                let range = NSMakeRange(0, self.attributedText!.length)
                
                let mutableAttributedText = NSMutableAttributedString(attributedString: newValue!)
                
                var standardAttributes: Array<Attribute> = []
                var linkAttributes: Array<LinkAttribute> = []
                
                self.attributedText!.enumerateAttributes(in: range, options: [], using: { (attributes, range, _) in
                    for attribute in attributes {
                        if attribute.key == .link {
                            if attribute.value is URL {
                                let linkAttribute = LinkAttribute(url: attribute.value as! URL, range: range)
                                linkAttributes.append(linkAttribute)
                            }
                        } else {
                            let attribute = Attribute(attributeName: attribute.key.rawValue, value: attribute.value as AnyObject, range: range)
                            standardAttributes.append(attribute)
                        }
                    }
                })
                
                self.standardTextAttributes = standardAttributes
                self.linkAttributes = linkAttributes
                
                super.attributedText = mutableAttributedText
            }
            
            self.setupAttributes()
        }
        get {
            return super.attributedText
        }
    }
    
    open weak var interactionDelegate: LinkLabelInteractionDelegate?
    
    override public init(frame: CGRect) {
        linkTextAttributes = [
            .underlineStyle: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)
        ]
        
        highlightedLinkTextAttributes = [
            .underlineStyle: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)
        ]
        
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        let touchGestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTouched(_:)))
        touchGestureRecognizer.delegate = self
        self.addGestureRecognizer(touchGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTapped(_:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        self.setupAttributes()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func link(atPoint point: CGPoint) -> URL? {
        let indexOfCharacter = self.indexOfCharacter(atPoint: point)
        
        if indexOfCharacter == nil {
            return nil
        }
        
        for linkAttribute in self.linkAttributes {
            if indexOfCharacter! >= linkAttribute.range.location &&
                indexOfCharacter! <= linkAttribute.range.location + linkAttribute.range.length {
                return linkAttribute.url
            }
        }
        
        return nil
    }
    
    @objc func respondToLinkLabelTouched(_ gestureRecognizer: TouchGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        //Possible states are began or cancelled
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let indexOfCharacterTouched = gestureRecognizer.indexOfCharacterTouched(label: self)
            
            if indexOfCharacterTouched != nil {
                for linkAttribute in self.linkAttributes {
                    if indexOfCharacterTouched! >= linkAttribute.range.location &&
                        indexOfCharacterTouched! <= linkAttribute.range.location + linkAttribute.range.length {
                            self.highlightedLinkAttribute = linkAttribute
                            return
                    }
                }
            }
            
            self.highlightedLinkAttribute = nil
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .failed || gestureRecognizer.state == .cancelled {
            self.highlightedLinkAttribute = nil
        }
        
    }
    
    @objc func respondToLinkLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        let indexOfCharacterTouched = gestureRecognizer.indexOfCharacterTouched(label: self)
        
        if indexOfCharacterTouched != nil  {
            for linkAttribute in self.linkAttributes {
                if indexOfCharacterTouched >= linkAttribute.range.location &&
                    indexOfCharacterTouched <= linkAttribute.range.location + linkAttribute.range.length {
                        self.interactionDelegate?.linkLabelDidSelectLink(linkLabel: self, url: linkAttribute.url)
                        break
                }
            }
        }
    }
    
    fileprivate func setupAttributes() {
        if self.attributedText == nil {
            super.attributedText = nil
            return
        }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        
        mutableAttributedText.removeAttributes()
        
        for attribute in self.standardTextAttributes {
            mutableAttributedText.addAttribute(
                NSAttributedStringKey(rawValue: attribute.attributeName),
                value: attribute.value,
                range: attribute.range
            )
        }
        
        for linkAttribute in self.linkAttributes {
            if linkAttribute === self.highlightedLinkAttribute {
                for (attribute, value) in self.highlightedLinkTextAttributes {
                    mutableAttributedText.addAttribute(attribute, value: value, range: linkAttribute.range)
                }
            } else {
                for (attribute, value)in self.linkTextAttributes {
                    mutableAttributedText.addAttribute(attribute, value: value, range: linkAttribute.range)
                }
            }
        }
        
        super.attributedText = mutableAttributedText
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
