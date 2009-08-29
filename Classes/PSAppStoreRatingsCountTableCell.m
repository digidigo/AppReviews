//
//  PSAppStoreRatingsCountTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreRatingsCountTableCell.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSHorizontalBarView.h"


#define kRatingsCountBarWidth	kRatingWidth
#define kRatingsCountBarHeight	16.0


@implementation PSAppStoreRatingsCountTableCell

@synthesize ratingView, countView, barView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
	{
        // Initialization code here.
		ratingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:ratingView];

		countView = [[PSCountView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:countView];

		CGRect countBounds = [PSCountView boundsForCount:[countView count] usingFontSize:countView.fontSize];
		barView = [[PSHorizontalBarView alloc] initWithFrame:CGRectMake(0, 0, kRatingsCountBarWidth, countBounds.size.height)];
		[self.contentView addSubview:barView];
    }
    return self;
}

- (void)dealloc
{
	[ratingView release];
	[countView release];
	[barView release];
    [super dealloc];
}

- (void)layoutSubviews
{
#define MARGIN_X 5
#define MARGIN_Y 5
#define INNER_MARGIN_X 10

    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;

	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	CGRect countBounds = [PSCountView boundsForCount:[countView count] usingFontSize:countView.fontSize];

	// Position rating view.
	frame = CGRectMake(boundsX + MARGIN_X, floorf(contentRect.origin.y + ((contentRect.size.height - kRatingHeight) / 2.0)), kRatingWidth, kRatingHeight);
	ratingView.frame = frame;

	// Position count.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (countBounds.size.width + INNER_MARGIN_X + kRatingsCountBarWidth + MARGIN_X), floorf(contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0)), countBounds.size.width, countBounds.size.height);
	countView.frame = frame;

	// Position bar.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (kRatingsCountBarWidth + MARGIN_X), floorf(contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0)), kRatingsCountBarWidth, countBounds.size.height);
	barView.frame = frame;
}

@end
