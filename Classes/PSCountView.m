//
//  PSCountView.m
//  EventHorizon
//
//  Created by Charles Gamble on 15/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSCountView.h"
#import <UIKit/UIColor.h>

#define kPSCounterMinWidth 20


@implementation PSCountView

@synthesize count, fontSize;


- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Initialization code
		self.count = 0;
		self.fontSize = 18.0;
		self.opaque = YES;
		self.clearsContextBeforeDrawing = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor whiteColor];
		//lozengeRed = 0.6;
		lozengeRed = 0.55;
		lozengeGreen = 0.6;
		//lozengeBlue = 0.6;
		lozengeBlue = 0.7;
		lozengeAlpha = 1.0;
		countRed = 1.0;
		countGreen = 1.0;
		countBlue = 1.0;
		countAlpha = 1.0;
 	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	// Drawing code
    if (count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		
        CGRect myRect = self.bounds;

		NSString *countString = [NSString stringWithFormat:@"%d", self.count];
		CGSize countSize = [countString sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]];
		CGFloat radius = myRect.size.height / 2.0;

		// Draw lozenge.
		CGContextSaveGState(context);
		CGContextSetRGBStrokeColor(context, lozengeRed, lozengeGreen, lozengeBlue, lozengeAlpha);
		CGContextSetLineWidth(context, myRect.size.height);
		CGContextSetLineCap(context, kCGLineCapRound);
		CGContextMoveToPoint(context, myRect.origin.x + radius, myRect.origin.y + radius);
		CGContextAddLineToPoint(context, myRect.origin.x + myRect.size.width - radius, myRect.origin.y + radius);
		CGContextStrokePath(context);
		CGContextRestoreGState(context);
		
		// Draw text.
		CGContextSetRGBFillColor(context, countRed, countGreen, countBlue, countAlpha);
		CGRect textRect = myRect;
		textRect.size.height = countSize.height;
		textRect.origin.y += ((myRect.size.height - countSize.height) / 2.0);
		//[countString drawInRect:myRect withFont:[UIFont systemFontOfSize:self.fontSize] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		[countString drawInRect:textRect withFont:[UIFont boldSystemFontOfSize:self.fontSize] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
}

- (void)dealloc
{
	[super dealloc];
}

// Class method that calculates the bounds required for a given count and font size.
// Can be used by parent view during layout.
+ (CGRect)boundsForCount:(NSUInteger)theCount usingFontSize:(CGFloat)theFontSize
{
    if (theCount == 0)
	{
        return CGRectZero;
    }
    
	// Calculate size of count.
	NSString *countString = [NSString stringWithFormat:@"%d", theCount];
	CGSize countSize = [countString sizeWithFont:[UIFont boldSystemFontOfSize:theFontSize]];
	CGFloat totalHeight = floor(countSize.height * 1.05);
	//totalHeight += ((NSUInteger)totalHeight % 2);	// Make sure height is an even number.
	CGFloat radius = totalHeight / 2.0;
    float countWidth = countSize.width;
    countWidth += (2 * radius-6.0);
    if (countWidth < kPSCounterMinWidth)
        countWidth = kPSCounterMinWidth;
    
	// Calculate frame of count within the parent cell.
    CGRect result;
    result.origin.x = 0;
    result.origin.y = 0;
    result.size.width = countWidth;
	result.size.height = totalHeight;
    
    return result;
}

- (void)setLozengeRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	lozengeRed = red;
	lozengeGreen = green;
	lozengeBlue = blue;
	lozengeAlpha = alpha;
	[self setNeedsDisplay];
}

- (void)setCountRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	countRed = red;
	countGreen = green;
	countBlue = blue;
	countAlpha = alpha;
	[self setNeedsDisplay];
}

- (void)setCount:(NSUInteger)theCount
{
	count = theCount;
	[self setNeedsDisplay];
}

- (void)setFontSize:(CGFloat)theSize
{
	fontSize = theSize;
	[self setNeedsDisplay];
}

@end
