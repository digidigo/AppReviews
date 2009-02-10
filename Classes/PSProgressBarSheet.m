//
//  PSProgressBarSheet.m
//  PSCommon
//
//  Created by Charles Gamble on 10/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSProgressBarSheet.h"


#define kProgressIndicatorSize	40.0


@interface UIActionSheet (Extended)

- (void)setMessage:(NSString *)message;
- (void)setNumberOfRows:(NSInteger)rows;

@end


@implementation PSProgressBarSheet

@synthesize parentView;

/**
 * Initializer.
 *
 * @param inTitle		Title to appear in progress sheet.
 * @param inParentView	Parent view of progress sheet.
 */
- (id)initWithTitle:(NSString *)title parentView:(UIView *)inParentView
{
	return [self initWithTitle:title parentView:(UIView *)inParentView delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

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
- (id)initWithTitle:(NSString *)title parentView:(UIView *)inParentView delegate:(id < UIActionSheetDelegate >)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
	if (self = [super initWithTitle:title delegate:delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil])
	{
		parentView = [inParentView retain];
		[self setNumberOfRows:5];
		
		// Setup a progress view (for determinate progress).
		progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
		[progressView setProgressViewStyle:UIProgressViewStyleDefault];
		[self addSubview:progressView];
		// Setup an indicator view (for indeterminate progress).
		activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		[activityView stopAnimating];
		activityView.hidesWhenStopped = YES;
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[self addSubview:activityView];
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
    [super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect viewBounds = self.bounds;
	CGRect frame;
	
	// Position progress view.
	frame = CGRectMake(viewBounds.origin.x + 50.0, viewBounds.origin.y + 80.0, viewBounds.size.width-100.0, 90.0);
	progressView.frame = frame;
	// Position activity view.
	frame = CGRectMake(viewBounds.origin.x + (viewBounds.size.width/2.0) - (kProgressIndicatorSize/2.0), viewBounds.origin.y + 70.0, kProgressIndicatorSize, kProgressIndicatorSize);
	activityView.frame = frame;
}

- (void) progressBeginWithMessage:(NSString *)message
{
	// Show progress sheet, initialised to 0% progress and showing an optional message.
	NSAssert(parentView, @"Parent view must be specified");
	progressView.hidden = YES;
	progressView.progress = 0.0;
	[activityView startAnimating];
	
	[self progressUpdateMessage:message];
	if ([parentView isKindOfClass:[UITabBar class]])
	{
		[self showFromTabBar:(UITabBar *)parentView];
	}
	else if ([parentView isKindOfClass:[UIToolbar class]])
	{
		[self showFromToolbar:(UIToolbar *)parentView];
	}
	else
	{
		[self showInView:parentView];
	}
}

- (void) progressEnd
{
	// Whatever it is has finished, dismiss sheet.
	[activityView stopAnimating];
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) progressUpdateMessage:(NSString *)message
{
	[self setMessage:message];
}

- (void) progressUpdate:(NSNumber *)progress
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


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
} 

@end
