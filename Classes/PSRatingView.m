//
//  PSRatingView.m
//  PSCommon
//
//  Created by Charles Gamble on 16/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
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
