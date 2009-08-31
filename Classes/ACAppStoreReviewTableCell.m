//
//  PSAppStoreReviewTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviewTableCell.h"
#import "PSAppStoreApplicationReview.h"
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

+ (NSString *)summaryTextForReview:(PSAppStoreApplicationReview *)review
{
	return [NSString stringWithFormat:@"%d. %@%@", review.index, review.summary, (review.appVersion?[NSString stringWithFormat:@" (%@)", review.appVersion]:@"")];
}

+ (CGFloat)tableView:(UITableView *)tableView heightForCellWithReview:(PSAppStoreApplicationReview *)inReview
{
#define MARGIN_X	5
#define MARGIN_Y	5

	CGFloat result = (3 * MARGIN_Y) + kRatingHeight;
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat contentWidth = screenBounds.size.width;
	contentWidth -= (2 * MARGIN_X);

	// Summary label.
	NSString *tmp = [self summaryTextForReview:inReview];
	CGSize itemSize = [tmp sizeWithFont:sSummaryFont constrainedToSize:CGSizeMake(contentWidth,CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	result += itemSize.height;

	// Detail label.
	// UITextView seems to have an 8-pixel margin on left/right, so reduce effective width when calculating height.
	itemSize = [inReview.detail sizeWithFont:sDetailFont constrainedToSize:CGSizeMake(screenBounds.size.width-(2*8.0),CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	NSUInteger numLines = (NSUInteger) ceilf(itemSize.height / sDetailFont.pointSize);
	result += (sDetailFont.pointSize * (numLines + 1));

	return result;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
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

		detailLabel = [[UITextView alloc] initWithFrame:CGRectZero];
		detailLabel.editable = NO;
		detailLabel.dataDetectorTypes = UIDataDetectorTypeAll;
		detailLabel.scrollEnabled = NO;
		detailLabel.backgroundColor = [UIColor whiteColor];
		detailLabel.opaque = YES;
		detailLabel.textColor = [UIColor blackColor];
		detailLabel.font = sDetailFont;
		detailLabel.textAlignment = UITextAlignmentLeft;
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

- (void)setReview:(PSAppStoreApplicationReview *)inReview
{
	[inReview retain];
	[review release];
	review = inReview;

	if (review)
	{
		self.summaryLabel.text = [PSAppStoreReviewTableCell summaryTextForReview:review];
		self.ratingView.rating = review.rating;
		self.authorLabel.text = [NSString stringWithFormat:@"by %@%@", review.reviewer, (review.reviewDate?[NSString stringWithFormat:@" on %@", review.reviewDate]:@"")];
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
	posX = boundsX;
	posY += itemHeight;
	itemWidth = contentRect.size.width;
	// UITextView seems to have an 8-pixel margin on left/right, so reduce effective width when calculating height.
	itemSize = [detailLabel.text sizeWithFont:detailLabel.font constrainedToSize:CGSizeMake(itemWidth-(2*8.0),CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	NSUInteger numLines = (NSUInteger) ceilf(itemSize.height / detailLabel.font.pointSize);
	itemHeight = (detailLabel.font.pointSize * (numLines + 1));
	frame = CGRectMake(posX, posY, itemWidth, itemHeight);
	detailLabel.frame = frame;
}

@end
