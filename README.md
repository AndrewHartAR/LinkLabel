# LinkLabel
UILabel with custom hyperlink styling, optional interaction delegate, minimal setup

## What’s up
Creating a UILabel with attributed text, links appear blue and underlined, and in most cases you don’t want them to be. It’s pretty awkward and a time-kill to try and make them simply be styled the way you desire.

LinkLabel makes this all easy. *Without any extra code*, links appear the same colour as the rest of your text, but underlined. It’s what the default *should* be.

If you want to add custom styling, that’s super simple, too. Same as you would specify attributes for your attributedText, any attributes you want to be different about your links, you add to LinkLabel’s `linkTextAttributes`, and `highlightedLinkTextAttributes`.

## Install
1. Drag contents of `Source` folder into your Xcode project.
2. Add `#import "UIKit/UIGestureRecognizerSubclass.h"` to Bridging Header file.

## Usage
1. Create a label using `LinkLabel`, instead of UILabel.

`let myLabel = LinkLabel()
`
2. Setup attributed text, including `NSLinkAttributeName`, as normal.

`    let text = "This is some text, which includes a link."
``    let fullRange = NSMakeRange(0, (text as NSString).length)
``    let linkRange = (text as NSString).rangeOfString("includes a link")
``    let attributedString = NSMutableAttributedString(string: text)
``    attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: fullRange)
``    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: fullRange)
``    attributedString.addAttribute(NSLinkAttributeName, value: NSURL(string: "https://google.com")!, range: linkRange)
`
3. If you wish to customise the link appearance:

`    let linkTextAttributes = 
``		NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
``		NSForegroundColorAttributeName: UIColor.greenColor()
``	]
``
``    let highlightedLinkTextAttributes = 
``        NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
``        NSForegroundColorAttributeName: UIColor.redColor()
``    ]
`
`    label.linkTextAttributes = linkTextAttributes
``    label.highlightedLinkTextAttributes = highlightedLinkTextAttributes
`
4. To make it easier to respond to link taps, I’ve added in an interaction delegate. Adopt `LinkLabelInteractionDelegate`, and then implement the delegate function:

`    label.interactionDelegate = self
`
`	//MARK: LinkLabelInteractionDelegate
``	
``	func linkLabelDidSelectLink(linkLabel linkLabel: LinkLabel, url: NSURL) {
``		print("did select link: \(url)")
``	}
`

