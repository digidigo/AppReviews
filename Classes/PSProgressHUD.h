//
//  PSProgressHUD.h
//  PSCommon
//
//  Created by Charles Gamble on 26/02/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSProgressHandler.h"


typedef enum
{
	PSProgressHUDBezelPositionCenter,
	PSProgressHUDBezelPositionTop,
	PSProgressHUDBezelPositionBottom
} PSProgressHUDBezelPosition;


/**
 * A subclass of UIView which displays a progress indicator. The progress indicator
 * can be determinate (0.0 - 1.0) or indeterminate (spinner).
 */
@interface PSProgressHUD : UIView <PSProgressHandler>
{
	UIView *parentView;
	UIProgressView *progressView;
	UIActivityIndicatorView *activityView;
	UILabel *titleLabel;
	UILabel *messageLabel;
	PSProgressHUDBezelPosition bezelPosition;
	CGSize bezelSize;
	UIColor *bezelColor;
	UIColor *textColor;
}

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, assign) PSProgressHUDBezelPosition bezelPosition;
@property (nonatomic, assign) CGSize bezelSize;
@property (nonatomic, retain) UIColor *bezelColor;
@property (nonatomic, retain) UIColor *textColor;


/**
 * Destructor.
 */
- (void)dealloc;

- (void) progressBeginWithMessage:(NSString *)message;
- (void) progressEnd;
- (void) progressUpdateMessage:(NSString *)inMessage;
- (void) progressUpdate:(NSNumber *)progress;

@end
