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

#import "PSRatingView.h"


static UIImage *sStarImage = nil;
static UIImage *sHalfStarImage = nil;


@implementation PSRatingView

@synthesize rating;

+ (void)initialize
{
	NSString *path = nil;

	path = [[NSBundle mainBundle] pathForResource:@"star" ofType:@"png"];
	NSAssert(path, @"Cannot find resource star.png");
	sStarImage = [[UIImage imageWithContentsOfFile:path] retain];

	path = [[NSBundle mainBundle] pathForResource:@"halfstar" ofType:@"png"];
	NSAssert(path, @"Cannot find resource halfstar.png");
	sHalfStarImage = [[UIImage imageWithContentsOfFile:path] retain];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        // Initialization code.
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.opaque = NO;
		self.clearsContextBeforeDrawing = YES;

		rating = 0;
    }
    return self;
}

- (void)setRating:(double)inRating
{
	if (inRating > 5.0)
		rating = 5.0;
	else if (inRating < 0.0)
		rating = 0.0;
	else
		rating = inRating;

	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	int wholeStars = floor(rating);
	BOOL halfStar = ((rating - (double)wholeStars) > 0.45);
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	for (int i = 0; i < wholeStars; i++)
	{
		xPos = (i * (kStarWidth + kStarMargin));
		[sStarImage drawAtPoint:CGPointMake(xPos, yPos)];
	}

	// Draw a half-star on the right if necessary.
	if (halfStar)
	{
		xPos = (wholeStars * (kStarWidth + kStarMargin));
		[sHalfStarImage drawAtPoint:CGPointMake(xPos, yPos)];
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end
