//
//  LinkLabel.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import UIKit

public protocol LinkLabelInteractionDelegate: class {
    func linkLabel(_ label: LinkLabel, didSelectLinkWith value: LinkLabel.LinkValue)
}

open class LinkLabel: UILabel, UIGestureRecognizerDelegate {
    
    public enum LinkValue: Equatable {
        case url(URL)
        case string(String)
    }
    
    private struct Attribute {
        let attributeName: String
        let value: AnyObject
        let range: NSRange
    }

    private struct LinkAttribute: Equatable {
        let value: LinkValue
        let range: NSRange
    }
    
    static private var defaultLinkTextAttributes: [NSAttributedString.Key : Any] {
        [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    static private var defaultHighlightedLinkTextAttributes: [NSAttributedString.Key : Any] {
        [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
            
    /// Text attributes displayed for all links
    open var linkTextAttributes: [NSAttributedString.Key: Any] {
        didSet {
            self.setupAttributes()
        }
    }
    
    /// Text attributes displayed when a link has been highlighted
    open var highlightedLinkTextAttributes: [NSAttributedString.Key: Any] {
        didSet {
            self.setupAttributes()
        }
    }
    
    private var linkAttributes: [LinkAttribute] = []
    
    private var standardTextAttributes: [Attribute] = []
    
    private var highlightedLinkAttribute: LinkAttribute? {
        didSet {
            guard highlightedLinkAttribute != oldValue else { return }
            self.setupAttributes()
        }
    }
    
    override open var attributedText: NSAttributedString? {
        set {
            super.attributedText = newValue
            if let attributedText = newValue {
                var standardAttributes: [Attribute] = []
                var linkAttributes: [LinkAttribute] = []
                
                let fullRange = NSMakeRange(0, attributedText.length)
                attributedText.enumerateAttributes(in: fullRange) { (attributes, range, _) in
                    for (key, value) in attributes {
                        switch key {
                        case .link:
                            if let url = value as? URL {
                                let linkAttribute = LinkAttribute(value: .url(url), range: range)
                                linkAttributes.append(linkAttribute)
                            } else if let string = value as? String {
                                let linkAttribute = LinkAttribute(value: .string(string), range: range)
                                linkAttributes.append(linkAttribute)
                            }
                        default:
                            let attribute = Attribute(
                                attributeName: key.rawValue,
                                value: value as AnyObject,
                                range: range
                            )
                            standardAttributes.append(attribute)
                        }
                    }
                }

                self.standardTextAttributes = standardAttributes
                self.linkAttributes = linkAttributes
                setupAttributes()
            }
        }
        get {
            super.attributedText
        }
    }
    
    open weak var interactionDelegate: LinkLabelInteractionDelegate?
    
    override public convenience init(frame: CGRect) {
        self.init(
            frame: frame,
            linkTextAttributes: LinkLabel.defaultLinkTextAttributes,
            highlightedLinkTextAttributes: LinkLabel.defaultHighlightedLinkTextAttributes
        )
    }
    
    public init(
        frame: CGRect = .zero,
        linkTextAttributes: [NSAttributedString.Key : Any],
        highlightedLinkTextAttributes: [NSAttributedString.Key : Any]
    ) {
        self.linkTextAttributes = linkTextAttributes
        self.highlightedLinkTextAttributes = highlightedLinkTextAttributes
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        linkTextAttributes = LinkLabel.defaultLinkTextAttributes
        highlightedLinkTextAttributes = LinkLabel.defaultHighlightedLinkTextAttributes
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        linkTextAttributes = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        highlightedLinkTextAttributes = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        isUserInteractionEnabled = true
        
        let touchGestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTouched))
        touchGestureRecognizer.delegate = self
        addGestureRecognizer(touchGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LinkLabel.respondToLinkLabelTapped))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        
        setupAttributes()
    }
    
    public func linkValue(atPoint point: CGPoint) -> LinkValue? {
        guard let charIndex = self.indexOfCharacter(atPoint: point) else {
            return nil
        }
        
        if let linkAttribute = linkAttributes.first(where: { NSLocationInRange(charIndex, $0.range) }) {
            return linkAttribute.value
        }
        
        return nil
    }
    
    @objc private func respondToLinkLabelTouched(_ gestureRecognizer: TouchGestureRecognizer) {
        guard linkAttributes.count > 0 else { return }
        
        // Possible states are began or cancelled
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            if let charIndex = gestureRecognizer.indexOfCharacterTouched(label: self),
               let linkAttribute = linkAttributes.first(where: { NSLocationInRange(charIndex, $0.range) }) {
                highlightedLinkAttribute = linkAttribute
                return
            }
            highlightedLinkAttribute = nil
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .failed || gestureRecognizer.state == .cancelled {
            highlightedLinkAttribute = nil
        }
    }
    
    @objc private func respondToLinkLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard linkAttributes.count > 0, let charIndex = gestureRecognizer.indexOfCharacterTouched(label: self) else { return }
        
        if let linkAttribute = linkAttributes.first(where: { NSLocationInRange(charIndex, $0.range) }) {
            interactionDelegate?.linkLabel(self, didSelectLinkWith: linkAttribute.value)
        }
    }
    
    private func setupAttributes() {
        guard let attributedString = attributedText else {
            super.attributedText = nil
            return
        }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedText.removeAttributes()
        
        for attribute in standardTextAttributes {
            mutableAttributedText.addAttribute(
                NSAttributedString.Key(rawValue: attribute.attributeName),
                value: attribute.value,
                range: attribute.range
            )
        }
        
        for linkAttribute in linkAttributes {
            if linkAttribute == highlightedLinkAttribute {
                for (attribute, value) in highlightedLinkTextAttributes {
                    mutableAttributedText.addAttribute(attribute, value: value, range: linkAttribute.range)
                }
            } else {
                for (attribute, value) in linkTextAttributes {
                    mutableAttributedText.addAttribute(attribute, value: value, range: linkAttribute.range)
                }
            }
        }
        
        super.attributedText = mutableAttributedText
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
