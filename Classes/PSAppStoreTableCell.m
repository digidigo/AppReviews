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

@synthesize nameLabel, flagView, ratingView, countView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:(NSString *)reuseIdentifier])
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
	
	NSArray *labelArray = [[NSArray alloc] initWithObjects:nameLabel, nil];
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
	frame = CGRectMake(boundsX + MARGIN_X + IMAGE_SIZE + MARGIN_X, LOWER_ROW_TOP, kRatingWidth, kRatingHeight);
	ratingView.frame = frame;
	
	// Position count.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (countBounds.size.width + MARGIN_X), contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0), countBounds.size.width, countBounds.size.height);
	countView.frame = frame;
}

@end
