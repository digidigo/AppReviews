//
//	Copyright (c) 2008-2009, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
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
//	* Neither the name of AppReviews nor the names of its contributors may be used
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

#import "PSCountView.h"
#import <UIKit/UIColor.h>


#define kPSCounterMinWidth 20


static CGFloat sDefaultLozengeRed = 0.55;
static CGFloat sDefaultLozengeGreen = 0.6;
static CGFloat sDefaultLozengeBlue = 0.7;
static CGFloat sDefaultLozengeAlpha = 1.0;
static CGFloat sDefaultCountRed = 1.0;
static CGFloat sDefaultCountGreen = 1.0;
static CGFloat sDefaultCountBlue = 1.0;
static CGFloat sDefaultCountAlpha = 1.0;


/**
 * Subclass of UIView which displays a positive count value in a lozenge.
 */
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
		lozengeRed = sDefaultLozengeRed;
		lozengeGreen = sDefaultLozengeGreen;
		lozengeBlue = sDefaultLozengeBlue;
		lozengeAlpha = sDefaultLozengeAlpha;
		countRed = sDefaultCountRed;
		countGreen = sDefaultCountGreen;
		countBlue = sDefaultCountBlue;
		countAlpha = sDefaultCountAlpha;
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
		[countString drawInRect:textRect withFont:[UIFont boldSystemFontOfSize:self.fontSize] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
}

- (void)dealloc
{
	[super dealloc];
}

/**
 * Calculates the bounds of the lozenge for a specified count and font, which allows
 * a parent view to perform sizing, layout, etc.
 *
 * @param theCount		The count value.
 * @param theFontSize	The font size.
 * @return CGRect containing the bounds required.
 */
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

/**
 * Sets the color of the lozenge.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
- (void)setLozengeRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	lozengeRed = red;
	lozengeGreen = green;
	lozengeBlue = blue;
	lozengeAlpha = alpha;
	[self setNeedsDisplay];
}

/**
 * Sets the color of the count.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
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

/**
 * Sets the color of the lozenge.
 *
 * @param inColor	UIColor for the lozenge.
 */
- (void)setLozengeColor:(UIColor *)inColor
{
	if (inColor)
	{
		CGColorRef colorRef = inColor.CGColor;
		size_t numComponents = CGColorGetNumberOfComponents(colorRef);
		if (numComponents == 2)
		{
			const CGFloat *components = CGColorGetComponents(colorRef);
			CGFloat all = components[0];
			CGFloat alpha = components[1];

			[self setLozengeRed:all green:all blue:all alpha:alpha];
		}
		else
		{
			const CGFloat *components = CGColorGetComponents(colorRef);
			CGFloat red = components[0];
			CGFloat green = components[1];
			CGFloat blue = components[2];
			CGFloat alpha = components[3];
			[self setLozengeRed:red green:green blue:blue alpha:alpha];
		}
	}
	else
	{
		[self setLozengeRed:sDefaultLozengeRed green:sDefaultLozengeGreen blue:sDefaultLozengeBlue alpha:sDefaultLozengeAlpha];
	}
}

/**
 * Sets the color of the count.
 *
 * @param inColor	UIColor for the count.
 */
- (void)setCountColor:(UIColor *)inColor
{
	if (inColor)
	{
		CGColorRef colorRef = inColor.CGColor;
		size_t numComponents = CGColorGetNumberOfComponents(colorRef);
		if (numComponents == 2)
		{
			const CGFloat *components = CGColorGetComponents(colorRef);
			CGFloat all = components[0];
			CGFloat alpha = components[1];

			[self setCountRed:all green:all blue:all alpha:alpha];
		}
		else
		{
			const CGFloat *components = CGColorGetComponents(colorRef);
			CGFloat red = components[0];
			CGFloat green = components[1];
			CGFloat blue = components[2];
			CGFloat alpha = components[3];
			[self setCountRed:red green:green blue:blue alpha:alpha];
		}
	}
	else
	{
		[self setCountRed:sDefaultCountRed green:sDefaultCountGreen blue:sDefaultCountBlue alpha:sDefaultCountAlpha];
	}
}

@end
