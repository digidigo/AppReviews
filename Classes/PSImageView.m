//
//  PSImageView.m
//  PSCommon
//
//  Created by Charles Gamble on 21/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSImageView.h"
#import <UIKit/UIColor.h>


/**
 * Subclass of UIView to display a UIImage centered within the view.
 */
@implementation PSImageView

@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Initialization code
		self.image = nil;
		self.opaque = YES;
		self.clearsContextBeforeDrawing = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor whiteColor];
 	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	if (self.image != nil)
	{
		CGRect contentRect = self.bounds;
		CGRect imgRect = CGRectMake(contentRect.origin.x + ((contentRect.size.width - image.size.width) / 2.0), contentRect.origin.y + ((contentRect.size.height - image.size.height) / 2.0), image.size.width, image.size.height);
		[image drawInRect:imgRect];
	}
}

- (void)dealloc
{
	[image release];
	[super dealloc];
}

- (void)setImage:(UIImage *)theImage
{
	[theImage retain];
	[image release];
	image = theImage;
	[self setNeedsDisplay];
}

@end
