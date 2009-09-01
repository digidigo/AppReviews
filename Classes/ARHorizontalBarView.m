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

#import "ARHorizontalBarView.h"
#import <UIKit/UIColor.h>


static CGFloat sDefaultBarRed = 0.55;
static CGFloat sDefaultBarGreen = 0.6;
static CGFloat sDefaultBarBlue = 0.7;
static CGFloat sDefaultBarAlpha = 1.0;


/**
 * Subclass of UIView which displays a filled bar representing a value between 0.0 and 1.0.
 */
@implementation ARHorizontalBarView

@synthesize barValue;


- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Initialization code
		self.barValue = 1.0;
		self.opaque = YES;
		self.clearsContextBeforeDrawing = YES;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor clearColor];
		barRed = sDefaultBarRed;
		barGreen = sDefaultBarGreen;
		barBlue = sDefaultBarBlue;
		barAlpha = sDefaultBarAlpha;
 	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect myRect = self.bounds;
	myRect.size.width = floorf(myRect.size.width * barValue);

	// Draw bar.
	CGContextSaveGState(context);
	CGContextSetRGBFillColor(context, barRed, barGreen, barBlue, barAlpha);
	CGContextFillRect(context, myRect);
	CGContextRestoreGState(context);
}

- (void)dealloc
{
	[super dealloc];
}

/**
 * Sets the color of the bar.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
- (void)setBarRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	barRed = red;
	barGreen = green;
	barBlue = blue;
	barAlpha = alpha;
	[self setNeedsDisplay];
}

- (void)setBarValue:(double)theBarValue
{
	barValue = theBarValue;

	if (barValue < 0.0)
		barValue = 0.0;
	else if (barValue > 1.0)
		barValue = 1.0;

	[self setNeedsDisplay];
}

/**
 * Sets the color of the bar.
 *
 * @param inColor	UIColor for the bar.
 */
- (void)setBarColor:(UIColor *)inColor
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

			[self setBarRed:all green:all blue:all alpha:alpha];
		}
		else
		{
			const CGFloat *components = CGColorGetComponents(colorRef);
			CGFloat red = components[0];
			CGFloat green = components[1];
			CGFloat blue = components[2];
			CGFloat alpha = components[3];
			[self setBarRed:red green:green blue:blue alpha:alpha];
		}
	}
	else
	{
		[self setBarRed:sDefaultBarRed green:sDefaultBarGreen blue:sDefaultBarBlue alpha:sDefaultBarAlpha];
	}
}

@end
