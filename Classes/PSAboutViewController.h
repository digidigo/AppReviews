//
//  PSAboutViewController.h
//  PSCommon
//
//  Created by Charles Gamble on 18/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Generic "About" view that shows the application name, icon, version and company details.
 * Fetches information from the Info.plist file. Allows user to visit website or send feedback email.
 */
@interface PSAboutViewController : UITableViewController <UIActionSheetDelegate>
{
	NSString *appName;
	UIImage *appIcon;
	NSString *appVersion;
	NSString *copyright;
	NSString *websiteURL;
	NSString *releaseNotesURL;
	NSString *email;
	NSString *appId;
	CGFloat applicationNameFontSize;
	UIView *parentViewForConfirmation;
}

/**
 * Allows overriding of the font size used for the application title.
 * Useful for applications with very long names.
 */
@property (nonatomic, assign) CGFloat applicationNameFontSize;

/**
 * Parent view used to determine how to show the confirmation view when
 * user taps on email or URL.
 */
@property (nonatomic, retain) UIView *parentViewForConfirmation;

/**
 * Initializer.
 */
- (id)init;

/**
 * Initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView;

/**
 * Initializer.
 */
- (id)initWithStyle:(UITableViewStyle)style;

/**
 * Designated initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView style:(UITableViewStyle)style;

/**
 * Destructor.
 */
- (void)dealloc;

@end
