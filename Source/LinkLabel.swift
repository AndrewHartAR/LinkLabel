//
//  LinkLabel.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import UIKit

private struct Attribute {
    let attributeName: NSAttributedString.Key
    let value: Any
    let range: NSRange
    
    init(attributeName: NSAttributedString.Key, value: Any, range: NSRange) {
        self.attributeName = attributeName
        self.value = value
        self.range = range
    }
}

private struct LinkAttribute: Equatable {
    let url: NSURL
    let range: NSRange
    
    init(url: NSURL, range: NSRange) {
        self.url = url
        self.range = range
    }
}

public protocol LinkLabelInteractionDelegate: class {
    func linkLabelDidSelectLink(linkLabel: LinkLabel, url: NSURL)
}

public class LinkLabel: UILabel, UIGestureRecognizerDelegate {
    
    private var linkAttributes: Array<LinkAttribute> = []
    
    private var standardTextAttributes: Array<Attribute> = []
    
    public var linkTextAttributes: Dictionary<NSAttributedString.Key, Any> {
        didSet {
            self.setupAttributes()
        }
    }
    
    //Text attributes displayed when a link has been highlighted
    public var highlightedLinkTextAttributes: Dictionary<NSAttributedString.Key, Any> {
        didSet {
            self.setupAttributes()
        }
    }
    
    private var highlightedLinkAttribute: LinkAttribute? {
        didSet {
            if self.highlightedLinkAttribute != oldValue {
                self.setupAttributes()
            }
        }
    }
    
    override public var attributedText: NSAttributedString? {
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
                
                self.attributedText!.enumerateAttributes(
                    in: range,
                    options: []) {
                        (attributes, range: NSRange, _) -> Void in
                        for (attributeName, value) in attributes {
                            
                            if attributeName == NSAttributedString.Key.link {
                                if value is NSURL {
                                    let linkAttribute = LinkAttribute(url: value as! NSURL, range: range)
                                    linkAttributes.append(linkAttribute)
                                }
                            } else {
                                let attribute = Attribute(attributeName: attributeName, value: value, range: range)
                                standardAttributes.append(attribute)
                            }
                        }
                }
                
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
    
    public weak var interactionDelegate: LinkLabelInteractionDelegate?
    
    override public init(frame: CGRect) {
        linkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single
        ]
        
        highlightedLinkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single
        ]
        
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        let touchGestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTouched))
        touchGestureRecognizer.delegate = self
        self.addGestureRecognizer(touchGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTapped))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        self.setupAttributes()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        linkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        highlightedLinkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        
        let touchGestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTouched))
        touchGestureRecognizer.delegate = self
        self.addGestureRecognizer(touchGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTapped))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        self.setupAttributes()
    }
    
    @objc func respondToLinkLabelTouched(gestureRecognizer: TouchGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        //Possible states are began or cancelled
        if gestureRecognizer.state == .began {
            
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
        }
        
        self.highlightedLinkAttribute = nil
    }
    
    @objc func respondToLinkLabelTapped(gestureRecognizer: UITapGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        let indexOfCharacterTouched = gestureRecognizer.indexOfCharacterTouched(label: self)
        
        if let indexOfCharacterTouched = indexOfCharacterTouched {
            for linkAttribute in self.linkAttributes {
                if indexOfCharacterTouched >= linkAttribute.range.location &&
                    indexOfCharacterTouched <= linkAttribute.range.location + linkAttribute.range.length {
                        self.interactionDelegate?.linkLabelDidSelectLink(linkLabel: self, url: linkAttribute.url)
                        break
                }
            }
        }
    }
    
    private func setupAttributes() {
        if self.attributedText == nil {
            super.attributedText = nil
            return
        }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        
        mutableAttributedText.removeAttributes()
        
        for attribute in self.standardTextAttributes {
            mutableAttributedText.addAttribute(attribute.attributeName, value: attribute.value, range: attribute.range)
        }
        
        for linkAttribute in self.linkAttributes {
            if linkAttribute == self.highlightedLinkAttribute {
                for (attributeName, value) in self.highlightedLinkTextAttributes {
                    mutableAttributedText.addAttribute(attributeName, value: value, range: linkAttribute.range)
                }
            } else {
                for (attributeName, value) in self.linkTextAttributes {
                    mutableAttributedText.addAttribute(attributeName, value: value, range: linkAttribute.range)
                }
            }
        }
        
        super.attributedText = mutableAttributedText
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
