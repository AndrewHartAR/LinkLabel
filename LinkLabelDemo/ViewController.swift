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
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white
        
        let text = "This is some text, which incidentally includes a link you may find interesting."
        let fullRange = NSMakeRange(0, (text as NSString).length)
        let linkRange = (text as NSString).range(of: "includes a link")
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15), range: fullRange)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: fullRange)
        attributedString.addAttribute(NSLinkAttributeName, value: URL(string: "https://google.com")!, range: linkRange)
        
        let linkTextAttributes = [
            NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int),
            NSForegroundColorAttributeName: UIColor.green
        ]
        
        let highlightedLinkTextAttributes = [
            NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int),
            NSForegroundColorAttributeName: UIColor.red
        ]
        
        let label = LinkLabel()
        label.numberOfLines = 0 // Infinite lines
        label.attributedText = attributedString
        label.linkTextAttributes = linkTextAttributes
        label.highlightedLinkTextAttributes = highlightedLinkTextAttributes
        label.interactionDelegate = self
        label.frame = CGRect(x: 20, y: 20, width: 280, height: 400)
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: LinkLabelInteractionDelegate
    
    func linkLabelDidSelectLink(linkLabel: LinkLabel, url: URL) {
        print("did select link: \(url)")
    }
}

