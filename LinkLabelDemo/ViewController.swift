//
//  ViewController.swift
//  LinkLabelDemo
//
//  Created by Andrew Hart on 24/11/2015.
//  Copyright © 2015 Project Dent. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LinkLabelInteractionDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let text = "This is some text, which incidentally includes a link you may find interesting."
        let fullRange = NSMakeRange(0, (text as NSString).length)
        let linkRange = (text as NSString).range(of: "includes a link")
        let link2Range = (text as NSString).range(of: "interesting")

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: fullRange)
        attributedString.addAttribute(.link, value: URL(string: "https://google.com")!, range: linkRange)
        attributedString.addAttribute(.link, value: "interesting_link", range: link2Range)
        
        let linkTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue as Int),
            .foregroundColor: UIColor.green
        ]
        
        let highlightedLinkTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue as Int),
            .foregroundColor: UIColor.red
        ]
        
        let label = LinkLabel()
        label.backgroundColor = UIColor.yellow
        label.numberOfLines = 0 // Infinite lines
        label.attributedText = attributedString
        label.linkTextAttributes = linkTextAttributes
        label.highlightedLinkTextAttributes = highlightedLinkTextAttributes
        label.interactionDelegate = self
        label.frame = CGRect(x: 20, y: 20, width: 280, height: 400)

        self.view.addSubview(label)
    }

    // MARK: LinkLabelInteractionDelegate
    
    func linkLabel(_ label: LinkLabel, didSelectLinkWith value: LinkLabel.LinkValue) {
        switch value {
        case .url(let url):
            print("did select link: \(url)")
        case .string(let string):
            print("did select link: \(string)")
        }
    }
}

