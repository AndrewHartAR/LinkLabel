//
//  ViewController.swift
//  LinkLabelDemo
//
//  Created by Andrew Hart on 24/11/2015.
//  Copyright © 2015 Project Dent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let text = "This is some text, which incidentally includes a link you may find interesting."
        let fullRange = NSMakeRange(0, (text as NSString).length)
        let linkRange = (text as NSString).rangeOfString("includes a link")
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: fullRange)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: fullRange)
        attributedString.addAttribute(NSLinkAttributeName, value: NSURL(string: "https://google.com")!, range: linkRange)
        
        let label = LinkLabel()
        label.numberOfLines = 0 // Infinite lines
        label.attributedText = attributedString
        label.frame = CGRect(x: 20, y: 20, width: 280, height: 400)
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

