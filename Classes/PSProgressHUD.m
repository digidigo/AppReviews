//
//	Copyright (c) 2008-2009, AppCritics
//	http://github.com/gambcl/AppCritics
//	http://www.perculasoft.com/appcritics
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppCritics nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "PSProgressHUD.h"


#define kProgressIndicatorSize	40.0
#define kPSShowProgressHUDAnimationID @"PSShowProgressHUDAnimationID"
#define kPSHideProgressHUDAnimationID @"PSHideProgressHUDAnimationID"


@implementation PSProgressHUD

@synthesize parentView, progressView, activityView, titleLabel, messageLabel, bezelPosition, bezelSize, bezelColor, textColor;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];

		parentView = nil;

		// Setup a progress view (for determinate progress).
		progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
		[progressView setProgressViewStyle:UIProgressViewStyleBar];
		[self addSubview:progressView];
		// Setup an indicator view (for indeterminate progress).
		activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		[activityView stopAnimating];
		activityView.hidesWhenStopped = YES;
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[self addSubview:activityView];
		// Setup the title label.
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		titleLabel.backgroundColor = [UIColor clearColor];
		//titleLabel.backgroundColor = [UIColor greenColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self addSubview:titleLabel];
		// Setup the message label.
		messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		messageLabel.font = [UIFont systemFontOfSize:14.0];
		messageLabel.backgroundColor = [UIColor clearColor];
		//messageLabel.backgroundColor = [UIColor greenColor];
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self addSubview:messageLabel];

		// Setup default colors.
		self.textColor = [UIColor whiteColor];
		self.bezelColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];

		self.bezelPosition = PSProgressHUDBezelPositionCenter;
		self.bezelSize = CGSizeMake(160.0, 160.0);
	}
	return self;
}

/**
 * Destructor.
 */
- (void)dealloc
{
	[parentView release];
	[progressView release];
	[activityView release];
	[titleLabel release];
	[messageLabel release];
	[bezelColor release];
	[textColor release];
    [super dealloc];
}

- (void)setTextColor:(UIColor *)inColor
{
	[inColor retain];
	[textColor release];
	textColor = inColor;

	titleLabel.textColor = textColor;
	messageLabel.textColor = textColor;
}

- (CGRect)rectForBezel
{
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGRect bezelBounds = CGRectMake(screenBounds.origin.x + floorf((screenBounds.size.width-bezelSize.width)/2.0), screenBounds.origin.y, bezelSize.width, bezelSize.height);
	// Adjust bezel coordinates for top, center, bottom as required.
	switch (bezelPosition)
	{
		case PSProgressHUDBezelPositionTop:
			break;
		case PSProgressHUDBezelPositionCenter:
			bezelBounds.origin.y = screenBounds.origin.y + floorf((screenBounds.size.height-bezelSize.height)/2.0);
			break;
		case PSProgressHUDBezelPositionBottom:
			bezelBounds.origin.y = (screenBounds.origin.y + screenBounds.size.height) - bezelSize.height;
			break;
	}

	return bezelBounds;
}

- (void)layoutSubviews
{
#define kOuterMargin 10.0
#define kProgressMargin 15.0
#define kTitleHeight 19.0
#define kMessageHeight 18.0
#define kProgressHeight 10.0

	[super layoutSubviews];

	CGRect frame;
	CGRect bezelBounds = [self rectForBezel];

	// Position progress view.
	frame = CGRectMake(bezelBounds.origin.x + kProgressMargin, bezelBounds.origin.y + floorf((bezelBounds.size.height/2.0) - (kProgressHeight/2.0)), bezelBounds.size.width-(2.0*kProgressMargin), kProgressHeight);
	progressView.frame = frame;
	// Position activity view.
	frame = CGRectMake(bezelBounds.origin.x + (bezelBounds.size.width/2.0) - (kProgressIndicatorSize/2.0), bezelBounds.origin.y + (bezelBounds.size.height/2.0) - (kProgressIndicatorSize/2.0), kProgressIndicatorSize, kProgressIndicatorSize);
	activityView.frame = frame;
	// Position title label.
	frame = CGRectMake(bezelBounds.origin.x + kOuterMargin, bezelBounds.origin.y + kOuterMargin, bezelBounds.size.width-(2.0*kOuterMargin), kTitleHeight);
	titleLabel.frame = frame;
	// Position message label.
	frame = CGRectMake(bezelBounds.origin.x + kOuterMargin, bezelBounds.origin.y + bezelBounds.size.height - (kMessageHeight + kOuterMargin), bezelBounds.size.width-(2.0*kOuterMargin), kMessageHeight);
	messageLabel.frame = frame;
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context
{
    float radius = 10.0f;

    CGContextBeginPath(context);
	CGContextSetFillColorWithColor(context, bezelColor.CGColor);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);

    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGRect bezelBounds = [self rectForBezel];

    CGContextRef context = UIGraphicsGetCurrentContext();
	[self fillRoundedRect:bezelBounds inContext:context];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	if ([animationID isEqualToString:kPSHideProgressHUDAnimationID])
	{
		// Progress view has just been faded out, now remove from view hierarchy.
		[self removeFromSuperview];
	}
}

- (void)progressBeginWithMessage:(NSString *)inMessage
{
	// Show progress sheet, initialised to 0% progress and showing an optional message.
	progressView.hidden = YES;
	progressView.progress = 0.0;
	[activityView startAnimating];

	[self progressUpdateMessage:inMessage];

	// Fade view in.
	self.alpha = 0.0;
	[parentView addSubview:self];
	[UIView beginAnimations:kPSShowProgressHUDAnimationID context:NULL];
	[UIView setAnimationDuration:0.4];
	self.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)progressEnd
{
	// Whatever it is has finished, dismiss sheet.
	[activityView stopAnimating];

	// Fade view out.
	[UIView beginAnimations:kPSHideProgressHUDAnimationID context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	self.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)progressUpdateMessage:(NSString *)inMessage
{
	self.messageLabel.text = inMessage;
}

- (void)progressUpdate:(NSNumber *)progress
{
	float value = [progress floatValue];
	if (value >= 0.0)
	{
		// Ensure we are in determinate progress mode.
		if ([activityView isAnimating])
		{
			// Stop (and hide) spinner.
			[activityView stopAnimating];
			// Show progress bar.
			progressView.hidden = NO;
		}
		progressView.progress = value;
	}
	else
	{
		// Ensure we are in indeterminate progress mode.
		if (progressView.hidden == NO)
		{
			// Hide progress bar.
			progressView.hidden = YES;
			// Start (and show) spinner.
			[activityView startAnimating];
		}
	}
}

@end
