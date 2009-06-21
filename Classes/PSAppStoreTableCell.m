//
//  PSAppStoreTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 16/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreTableCell.h"
#import "PSImageView.h"
#import "PSRatingView.h"
#import "PSCountView.h"


@implementation PSAppStoreTableCell

@synthesize nameLabel, flagView, ratingView, ratingCountLabel, countView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
	{
        // Initialization code here.
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.backgroundColor = [UIColor whiteColor];
		nameLabel.opaque = YES;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:15];
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:nameLabel];

		flagView = [[PSImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:flagView];

		ratingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:ratingView];

		ratingCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		ratingCountLabel.backgroundColor = [UIColor whiteColor];
		ratingCountLabel.opaque = YES;
		ratingCountLabel.textColor = [UIColor blackColor];
		ratingCountLabel.highlightedTextColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.7 alpha:1.0];
		ratingCountLabel.font = [UIFont systemFontOfSize:14.0];
		ratingCountLabel.textAlignment = UITextAlignmentLeft;
		ratingCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:ratingCountLabel];

		countView = [[PSCountView alloc] initWithFrame:CGRectZero];
		countView.fontSize = nameLabel.font.pointSize;
		[self.contentView addSubview:countView];
    }
    return self;
}

- (void)dealloc
{
	[nameLabel release];
	[flagView release];
	[ratingView release];
	[ratingCountLabel release];
	[countView release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background,
	 so in newLabelForMainText: the labels are made opaque and given a white background.
	 To show selection properly, however, the views need to be transparent (so that the selection color shows through).
    */
	[super setSelected:selected animated:animated];

	UIColor *backgroundColor = nil;
	if (selected)
	{
	    backgroundColor = [UIColor clearColor];
	}
	else
	{
		backgroundColor = [UIColor whiteColor];
	}

	NSArray *labelArray = [[NSArray alloc] initWithObjects:nameLabel, ratingCountLabel, nil];
	for (UILabel *label in labelArray)
	{
		label.backgroundColor = backgroundColor;
		label.highlighted = selected;
		label.opaque = !selected;
	}
	[labelArray release];
}

- (void)layoutSubviews
{
#define MARGIN_X 5
#define INNER_MARGIN_X 4
#define MARGIN_Y 5
#define UPPER_ROW_TOP 3
#define LOWER_ROW_TOP 23
#define IMAGE_SIZE 32

    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;

	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	CGRect countBounds = [PSCountView boundsForCount:[countView count] usingFontSize:nameLabel.font.pointSize];

	// Position name label.
	frame = CGRectMake(boundsX + MARGIN_X + IMAGE_SIZE + MARGIN_X, UPPER_ROW_TOP, contentRect.size.width-(MARGIN_X + IMAGE_SIZE + MARGIN_X + MARGIN_X + countBounds.size.width + MARGIN_X), 20.0);
	nameLabel.frame = frame;

	// Position flag view.
	frame = CGRectMake(boundsX + MARGIN_X, floorf((contentRect.size.height-IMAGE_SIZE)/2.0), IMAGE_SIZE, IMAGE_SIZE);
	flagView.frame = frame;

	// Position rating view.
	CGFloat realRatingWidth = (ratingView.rating * kStarWidth) + ((ceilf(ratingView.rating)-1.0) * kStarMargin);
	frame = CGRectMake(boundsX + MARGIN_X + IMAGE_SIZE + MARGIN_X, LOWER_ROW_TOP, kRatingWidth, kRatingHeight);
	ratingView.frame = frame;

	// Position rating count label.
	CGSize itemSize = [ratingCountLabel.text sizeWithFont:ratingCountLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(boundsX + MARGIN_X + IMAGE_SIZE + MARGIN_X + realRatingWidth + INNER_MARGIN_X, LOWER_ROW_TOP, contentRect.size.width-(IMAGE_SIZE+realRatingWidth+countBounds.size.width+INNER_MARGIN_X + (4*MARGIN_X)), itemSize.height);
	ratingCountLabel.frame = frame;

	// Position count.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (countBounds.size.width + MARGIN_X), contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0), countBounds.size.width, countBounds.size.height);
	countView.frame = frame;
}

@end
