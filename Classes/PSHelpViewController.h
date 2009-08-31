//
//  PSHelpViewController.h
//  PSCommon
//
//  Created by Charles Gamble on 24/07/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Help view which is just a wrapper around a UIWebView.
 * Loads a specified URL.
 */
@interface PSHelpViewController : UIViewController
{
	NSURL *contentURL;
    UIWebView *webView;
	NSString *viewTitle;
}

/**
 * URL giving the location of the help content.
 */
@property (nonatomic, copy) NSURL *contentURL;

/**
 * Title to be shown in the navigation bar.
 */
@property (nonatomic, copy) NSString *viewTitle;

@end
