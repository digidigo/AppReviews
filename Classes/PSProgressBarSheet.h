//
//  PSProgressBarSheet.h
//  Common
//
//  Created by Charles Gamble on 10/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSProgressHandler.h"

/**
 * A subclass of UIActionSheet which displays a progress indicator. The progress indicator
 * can be determinate (0.0 - 1.0) or indeterminate (spinner).
 */
@interface PSProgressBarSheet : UIActionSheet <PSProgressHandler, UIActionSheetDelegate>
{
	UIView *parentView;
	UIProgressView *progressView;
	UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UIView *parentView;

/**
 * Initializer.
 *
 * @param inTitle		Title to appear in progress sheet.
 * @param inParentView	Parent view of progress sheet.
 */
- (id)initWithTitle:(NSString *)inTitle parentView:(UIView *)inParentView;

/**
 * Designated initializer.
 *
 * @param inTitle					Title to appear in progress sheet.
 * @param inParentView				Parent view of progress sheet.
 * @param delegate					Ignored.
 * @param cancelButtonTitle			Ignored.
 * @param destructiveButtonTitle	Ignored.
 * @param otherButtonTitles			Ignored.
 */
- (id)initWithTitle:(NSString *)title parentView:(UIView *)inParentView delegate:(id < UIActionSheetDelegate >)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles;

/**
 * Destructor.
 */
- (void)dealloc;

- (void) progressBeginWithMessage:(NSString *)message;
- (void) progressEnd;
- (void) progressUpdateMessage:(NSString *)message;
- (void) progressUpdate:(NSNumber *)progress;

@end
