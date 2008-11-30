//
//  PSAppStoreReviewTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviewTableCell.h"
#import "PSAppStoreReview.h"
#import "PSRatingView.h"
#import <UIKit/UIStringDrawing.h>


static UIFont *sSummaryFont = nil;
static UIFont *sDetailFont = nil;

@implementation PSAppStoreReviewTableCell

@synthesize summaryLabel, authorLabel, detailLabel, ratingView, review;

+ (void)initialize
{
	sSummaryFont = [[UIFont boldSystemFontOfSize:14.0] retain];
	sDetailFont = [[UIFont systemFontOfSize:13.0] retain];
}

+ (CGFloat)tableView:(UITableView *)tableView heightForCellWithReview:(PSAppStoreReview *)inReview
{
#define MARGIN_X	5
#define MARGIN_Y	5
	
	CGFloat result = (4 * MARGIN_Y) + kRatingHeight;
	CGFloat contentWidth = tableView.contentSize.width;
	contentWidth -= (2 * MARGIN_X);
	
	// Summary label.
	NSString *tmp = [NSString stringWithFormat:@"%d. %@", inReview.index, inReview.summary];
	CGSize itemSize = [tmp sizeWithFont:sSummaryFont constrainedToSize:CGSizeMake(contentWidth,CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	result += itemSize.height;
	
	// Detail label.
	itemSize = [inReview.detail sizeWithFont:sDetailFont constrainedToSize:CGSizeMake(contentWidth,CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	result += itemSize.height;
	
	return result;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		summaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		summaryLabel.backgroundColor = [UIColor clearColor];
		summaryLabel.opaque = YES;
		summaryLabel.textColor = [UIColor blackColor];
		summaryLabel.highlightedTextColor = [UIColor whiteColor];
		summaryLabel.font = sSummaryFont;
		summaryLabel.textAlignment = UITextAlignmentLeft;
		summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
		summaryLabel.numberOfLines = 0;
		[self.contentView addSubview:summaryLabel];
		
		
		authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		authorLabel.backgroundColor = [UIColor clearColor];
		authorLabel.opaque = YES;
		authorLabel.textColor = [UIColor darkGrayColor];
		authorLabel.highlightedTextColor = [UIColor whiteColor];
		authorLabel.font = [UIFont systemFontOfSize:13.0];
		authorLabel.textAlignment = UITextAlignmentLeft;
		authorLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:authorLabel];

		detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.opaque = YES;
		detailLabel.textColor = [UIColor blackColor];
		detailLabel.highlightedTextColor = [UIColor whiteColor];
		detailLabel.font = sDetailFont;
		detailLabel.textAlignment = UITextAlignmentLeft;
		detailLabel.lineBreakMode = UILineBreakModeWordWrap;
		detailLabel.numberOfLines = 0;
		[self.contentView addSubview:detailLabel];

		ratingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:ratingView];
		
		self.review = nil;
    }
    return self;
}

- (void)dealloc
{
	[summaryLabel release];
	[authorLabel release];
	[detailLabel release];
	[ratingView release];
	[review release];
    [super dealloc];
}

- (void)setReview:(PSAppStoreReview *)inReview
{
	[inReview retain];
	[review release];
	review = inReview;
	
	if (review)
	{
		self.summaryLabel.text = [NSString stringWithFormat:@"%d. %@", review.index, review.summary];
		self.ratingView.rating = review.rating;
		self.authorLabel.text = [NSString stringWithFormat:@"by %@", review.reviewer];
		self.detailLabel.text = review.detail;
	}
	else
	{
		self.summaryLabel.text = @"";
		self.ratingView.rating = 0.0;
		self.authorLabel.text = @"";
		self.detailLabel.text = @"";
	}
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	/*[summaryLabel setNeedsLayout];
	[summaryLabel setNeedsDisplay];
	[ratingView setNeedsLayout];
	[ratingView setNeedsDisplay];
	[authorLabel setNeedsLayout];
	[authorLabel setNeedsDisplay];
	[detailLabel setNeedsLayout];
	[detailLabel setNeedsDisplay];*/
}

- (void)layoutSubviews
{
#define MARGIN_X	5
#define MARGIN_Y	5
	
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGFloat posX, posY, itemWidth, itemHeight;
	CGRect frame;
	
	// Position summary label.
	posX = boundsX + MARGIN_X;
	posY = boundsY + MARGIN_Y;
	itemWidth = contentRect.size.width-(MARGIN_X + MARGIN_X);
	CGSize itemSize = [summaryLabel.text sizeWithFont:summaryLabel.font constrainedToSize:CGSizeMake(itemWidth,CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	itemHeight = itemSize.height;
	summaryLabel.numberOfLines = (int)itemHeight / (int)summaryLabel.font.pointSize;
	frame = CGRectMake(posX, posY, itemWidth, itemHeight);
	summaryLabel.frame = frame;
	
	// Position rating view.
	posX = boundsX + MARGIN_X;
	posY += (itemHeight + MARGIN_Y);
	itemWidth = kRatingWidth;
	itemHeight = kRatingHeight;
	frame = CGRectMake(posX, posY, itemWidth, itemHeight);
	ratingView.frame = frame;
	
	// Position author label.
	CGFloat realRatingWidth = (ratingView.rating * kStarWidth) + ((ceilf(ratingView.rating)-1.0) * kStarMargin);
	posX += (realRatingWidth + MARGIN_X);
	itemWidth = contentRect.size.width-(MARGIN_X + realRatingWidth + MARGIN_X + MARGIN_X);
	itemHeight = kRatingHeight;
	frame = CGRectMake(posX, posY, itemWidth, itemHeight);
	authorLabel.frame = frame;
	
	// Position detail label.
	posX = boundsX + MARGIN_X;
	posY += (itemHeight + MARGIN_Y);
	itemWidth = contentRect.size.width-(MARGIN_X + MARGIN_X);
	itemSize = [detailLabel.text sizeWithFont:detailLabel.font constrainedToSize:CGSizeMake(itemWidth,CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	itemHeight = itemSize.height;
	detailLabel.numberOfLines = (int)itemHeight / (int)detailLabel.font.pointSize;
	frame = CGRectMake(posX, posY, itemWidth, itemHeight);
	detailLabel.frame = frame;	
}

@end
