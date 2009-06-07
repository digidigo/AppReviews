//
//  PSAppStoreReviewsHeaderTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 21/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviewsHeaderTableCell.h"
#import "PSAppReviewsStore.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreApplication.h"
#import "PSRatingView.h"
#import "UIColor+MoreColors.h"
#import "AppCriticsAppDelegate.h"


static UIColor *sLabelColor = nil;
static CGGradientRef sGradient = NULL;


@implementation PSAppStoreReviewsHeaderTableCell

@synthesize appDetails, appCompany, versionLabel, versionValue, sizeLabel, sizeValue, dateLabel, dateValue;
@synthesize priceLabel, priceValue;
@synthesize currentTitle, currentVersionLabel, currentRatingsLabel, currentRatingsValue, currentRatingsView, currentReviewsLabel, currentReviewsValue;
@synthesize allTitle, allVersionsLabel, allRatingsLabel, allRatingsValue, allRatingsView, allReviewsLabel, allReviewsValue;

+ (void)initialize
{
	sLabelColor = [[UIColor tableCellTextBlue] retain];

	// Create the gradient.
	CGColorSpaceRef myColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 235.0/255.0, 238.0/255.0, 245.0/255.0, 1.0,	// Start color
							  159.0/255.0, 158.0/255.0, 163.0/255.0, 1.0 };	// End color
	myColorspace = CGColorSpaceCreateDeviceRGB();
	sGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	CGColorSpaceRelease(myColorspace);
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
#define TITLE_FONT_SIZE 24.0
#define DETAIL_FONT_SIZE 14.0

    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
        // Initialization code
		self.clearsContextBeforeDrawing = YES;
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		appName = [[UILabel alloc] initWithFrame:CGRectZero];
		appName.backgroundColor = [UIColor clearColor];
		appName.opaque = NO;
		appName.textColor = [UIColor blackColor];
		appName.highlightedTextColor = [UIColor whiteColor];
		appName.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
		appName.textAlignment = UITextAlignmentLeft;
		appName.lineBreakMode = UILineBreakModeTailTruncation;
		appName.adjustsFontSizeToFitWidth = YES;
		appName.minimumFontSize = 10.0;
		appName.numberOfLines = 1;
		[self.contentView addSubview:appName];

		appCompany = [[UILabel alloc] initWithFrame:CGRectZero];
		appCompany.backgroundColor = [UIColor clearColor];
		appCompany.opaque = NO;
		appCompany.textColor = [UIColor blackColor];
		appCompany.highlightedTextColor = [UIColor whiteColor];
		appCompany.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		appCompany.textAlignment = UITextAlignmentLeft;
		appCompany.lineBreakMode = UILineBreakModeTailTruncation;
		appCompany.adjustsFontSizeToFitWidth = YES;
		appCompany.minimumFontSize = 10.0;
		appCompany.numberOfLines = 1;
		[self.contentView addSubview:appCompany];

		priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.opaque = NO;
		priceLabel.textColor = sLabelColor;
		priceLabel.highlightedTextColor = [UIColor whiteColor];
		priceLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		priceLabel.textAlignment = UITextAlignmentLeft;
		priceLabel.lineBreakMode = UILineBreakModeTailTruncation;
		priceLabel.numberOfLines = 1;
		priceLabel.text = @"Price:";
		[self.contentView addSubview:priceLabel];

		priceValue = [[UILabel alloc] initWithFrame:CGRectZero];
		priceValue.backgroundColor = [UIColor clearColor];
		priceValue.opaque = NO;
		priceValue.textColor = [UIColor blackColor];
		priceValue.highlightedTextColor = [UIColor whiteColor];
		priceValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		priceValue.textAlignment = UITextAlignmentLeft;
		priceValue.lineBreakMode = UILineBreakModeTailTruncation;
		priceValue.numberOfLines = 1;
		[self.contentView addSubview:priceValue];

		dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.opaque = NO;
		dateLabel.textColor = sLabelColor;
		dateLabel.highlightedTextColor = [UIColor whiteColor];
		dateLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		dateLabel.textAlignment = UITextAlignmentLeft;
		dateLabel.lineBreakMode = UILineBreakModeTailTruncation;
		dateLabel.numberOfLines = 1;
		dateLabel.text = @"Released:";
		[self.contentView addSubview:dateLabel];

		dateValue = [[UILabel alloc] initWithFrame:CGRectZero];
		dateValue.backgroundColor = [UIColor clearColor];
		dateValue.opaque = NO;
		dateValue.textColor = [UIColor blackColor];
		dateValue.highlightedTextColor = [UIColor whiteColor];
		dateValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		dateValue.textAlignment = UITextAlignmentLeft;
		dateValue.lineBreakMode = UILineBreakModeTailTruncation;
		dateValue.numberOfLines = 1;
		[self.contentView addSubview:dateValue];

		currentTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		currentTitle.backgroundColor = sLabelColor;
		currentTitle.opaque = NO;
		currentTitle.textColor = [UIColor whiteColor];
		currentTitle.highlightedTextColor = [UIColor whiteColor];
		currentTitle.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		currentTitle.textAlignment = UITextAlignmentLeft;
		currentTitle.lineBreakMode = UILineBreakModeTailTruncation;
		currentTitle.numberOfLines = 1;
		currentTitle.text = @" Current Version";
		[self.contentView addSubview:currentTitle];

		currentRatingsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		currentRatingsLabel.backgroundColor = [UIColor clearColor];
		currentRatingsLabel.opaque = NO;
		currentRatingsLabel.textColor = sLabelColor;
		currentRatingsLabel.highlightedTextColor = [UIColor whiteColor];
		currentRatingsLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		currentRatingsLabel.textAlignment = UITextAlignmentLeft;
		currentRatingsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		currentRatingsLabel.numberOfLines = 1;
		currentRatingsLabel.text = @"Ratings:";
		[self.contentView addSubview:currentRatingsLabel];

		currentRatingsView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:currentRatingsView];

		currentRatingsValue = [[UILabel alloc] initWithFrame:CGRectZero];
		currentRatingsValue.backgroundColor = [UIColor clearColor];
		currentRatingsValue.opaque = NO;
		currentRatingsValue.textColor = [UIColor blackColor];
		currentRatingsValue.highlightedTextColor = [UIColor whiteColor];
		currentRatingsValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		currentRatingsValue.textAlignment = UITextAlignmentLeft;
		currentRatingsValue.lineBreakMode = UILineBreakModeTailTruncation;
		currentRatingsValue.numberOfLines = 1;
		[self.contentView addSubview:currentRatingsValue];

		currentReviewsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		currentReviewsLabel.backgroundColor = [UIColor clearColor];
		currentReviewsLabel.opaque = NO;
		currentReviewsLabel.textColor = sLabelColor;
		currentReviewsLabel.highlightedTextColor = [UIColor whiteColor];
		currentReviewsLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		currentReviewsLabel.textAlignment = UITextAlignmentLeft;
		currentReviewsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		currentReviewsLabel.numberOfLines = 1;
		currentReviewsLabel.text = @"Reviews:";
		[self.contentView addSubview:currentReviewsLabel];

		currentReviewsValue = [[UILabel alloc] initWithFrame:CGRectZero];
		currentReviewsValue.backgroundColor = [UIColor clearColor];
		currentReviewsValue.opaque = NO;
		currentReviewsValue.textColor = [UIColor blackColor];
		currentReviewsValue.highlightedTextColor = [UIColor whiteColor];
		currentReviewsValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		currentReviewsValue.textAlignment = UITextAlignmentLeft;
		currentReviewsValue.lineBreakMode = UILineBreakModeTailTruncation;
		currentReviewsValue.numberOfLines = 1;
		[self.contentView addSubview:currentReviewsValue];

		allTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		allTitle.backgroundColor = sLabelColor;
		allTitle.opaque = NO;
		allTitle.textColor = [UIColor whiteColor];
		allTitle.highlightedTextColor = [UIColor whiteColor];
		allTitle.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		allTitle.textAlignment = UITextAlignmentLeft;
		allTitle.lineBreakMode = UILineBreakModeTailTruncation;
		allTitle.numberOfLines = 1;
		allTitle.text = @" All Versions";
		[self.contentView addSubview:allTitle];

		allRatingsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		allRatingsLabel.backgroundColor = [UIColor clearColor];
		allRatingsLabel.opaque = NO;
		allRatingsLabel.textColor = sLabelColor;
		allRatingsLabel.highlightedTextColor = [UIColor whiteColor];
		allRatingsLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		allRatingsLabel.textAlignment = UITextAlignmentLeft;
		allRatingsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		allRatingsLabel.numberOfLines = 1;
		allRatingsLabel.text = @"Ratings:";
		[self.contentView addSubview:allRatingsLabel];

		allRatingsView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:allRatingsView];

		allRatingsValue = [[UILabel alloc] initWithFrame:CGRectZero];
		allRatingsValue.backgroundColor = [UIColor clearColor];
		allRatingsValue.opaque = NO;
		allRatingsValue.textColor = [UIColor blackColor];
		allRatingsValue.highlightedTextColor = [UIColor whiteColor];
		allRatingsValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		allRatingsValue.textAlignment = UITextAlignmentLeft;
		allRatingsValue.lineBreakMode = UILineBreakModeTailTruncation;
		allRatingsValue.numberOfLines = 1;
		[self.contentView addSubview:allRatingsValue];

		allReviewsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		allReviewsLabel.backgroundColor = [UIColor clearColor];
		allReviewsLabel.opaque = NO;
		allReviewsLabel.textColor = sLabelColor;
		allReviewsLabel.highlightedTextColor = [UIColor whiteColor];
		allReviewsLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		allReviewsLabel.textAlignment = UITextAlignmentLeft;
		allReviewsLabel.lineBreakMode = UILineBreakModeTailTruncation;
		allReviewsLabel.numberOfLines = 1;
		allReviewsLabel.text = @"Reviews:";
		[self.contentView addSubview:allReviewsLabel];

		allReviewsValue = [[UILabel alloc] initWithFrame:CGRectZero];
		allReviewsValue.backgroundColor = [UIColor clearColor];
		allReviewsValue.opaque = NO;
		allReviewsValue.textColor = [UIColor blackColor];
		allReviewsValue.highlightedTextColor = [UIColor whiteColor];
		allReviewsValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		allReviewsValue.textAlignment = UITextAlignmentLeft;
		allReviewsValue.lineBreakMode = UILineBreakModeTailTruncation;
		allReviewsValue.numberOfLines = 1;
		[self.contentView addSubview:allReviewsValue];

		versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		versionLabel.backgroundColor = [UIColor clearColor];
		versionLabel.opaque = NO;
		versionLabel.textColor = sLabelColor;
		versionLabel.highlightedTextColor = [UIColor whiteColor];
		versionLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		versionLabel.textAlignment = UITextAlignmentRight;
		versionLabel.lineBreakMode = UILineBreakModeTailTruncation;
		versionLabel.numberOfLines = 1;
		versionLabel.text = @"Version:";
		[self.contentView addSubview:versionLabel];

		versionValue = [[UILabel alloc] initWithFrame:CGRectZero];
		versionValue.backgroundColor = [UIColor clearColor];
		versionValue.opaque = NO;
		versionValue.textColor = [UIColor blackColor];
		versionValue.highlightedTextColor = [UIColor whiteColor];
		versionValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		versionValue.textAlignment = UITextAlignmentRight;
		versionValue.lineBreakMode = UILineBreakModeTailTruncation;
		versionValue.numberOfLines = 1;
		[self.contentView addSubview:versionValue];

		sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		sizeLabel.backgroundColor = [UIColor clearColor];
		sizeLabel.opaque = NO;
		sizeLabel.textColor = sLabelColor;
		sizeLabel.highlightedTextColor = [UIColor whiteColor];
		sizeLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		sizeLabel.textAlignment = UITextAlignmentRight;
		sizeLabel.lineBreakMode = UILineBreakModeTailTruncation;
		sizeLabel.numberOfLines = 1;
		sizeLabel.text = @"Size:";
		[self.contentView addSubview:sizeLabel];

		sizeValue = [[UILabel alloc] initWithFrame:CGRectZero];
		sizeValue.backgroundColor = [UIColor clearColor];
		sizeValue.opaque = NO;
		sizeValue.textColor = [UIColor blackColor];
		sizeValue.highlightedTextColor = [UIColor whiteColor];
		sizeValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		sizeValue.textAlignment = UITextAlignmentRight;
		sizeValue.lineBreakMode = UILineBreakModeTailTruncation;
		sizeValue.numberOfLines = 1;
		[self.contentView addSubview:sizeValue];

		self.appDetails = nil;
    }
    return self;
}

- (void)dealloc
{
	[appName release];
	[appCompany release];
	[versionLabel release];
	[versionValue release];
	[sizeLabel release];
	[sizeValue release];
	[dateLabel release];
	[dateValue release];
	[priceLabel release];
	[priceValue release];
	[currentTitle release];
	[currentVersionLabel release];
	[currentRatingsLabel release];
	[currentRatingsValue release];
	[currentRatingsView release];
	[currentReviewsLabel release];
	[currentReviewsValue release];
	[allTitle release];
	[allVersionsLabel release];
	[allRatingsLabel release];
	[allRatingsValue release];
	[allRatingsView release];
	[allReviewsLabel release];
	[allReviewsValue release];
	[appDetails release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = 0.0;
	myEndPoint.x = 0.0;
	myEndPoint.y = self.bounds.size.height - 1.0;
	CGContextDrawLinearGradient (context, sGradient, myStartPoint, myEndPoint, 0);
}

- (void)layoutSubviews
{
#define MARGIN_X	7
#define MARGIN_Y	1
#define INNER_MARGIN_X	4
#define INNER_MARGIN_Y	0
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGRect frame;
	CGFloat posX;
	CGFloat posY;

	// App name label.
	posX = boundsX + MARGIN_X;
	posY = boundsY + MARGIN_Y;
	CGSize itemSize = [appName.text sizeWithFont:appName.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, contentRect.size.width-(2*MARGIN_X), itemSize.height);
	appName.frame = frame;

	// App company label.
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [appCompany.text sizeWithFont:appCompany.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, contentRect.size.width-(2*MARGIN_X), itemSize.height);
	appCompany.frame = frame;

	// Price label.
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [priceLabel.text sizeWithFont:priceLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	priceLabel.frame = frame;
	// Price value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [priceValue.text sizeWithFont:priceValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	priceValue.frame = frame;
	// Version value.
	itemSize = [versionValue.text sizeWithFont:versionValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX = boundsX + contentRect.size.width - (MARGIN_X + itemSize.width);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	versionValue.frame = frame;
	// Version label.
	itemSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX -= (itemSize.width + INNER_MARGIN_X);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	versionLabel.frame = frame;

	// Date label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	dateLabel.frame = frame;
	// Date value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [dateValue.text sizeWithFont:dateValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	dateValue.frame = frame;
	// Size value.
	itemSize = [sizeValue.text sizeWithFont:sizeValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX = boundsX + contentRect.size.width - (MARGIN_X + itemSize.width);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	sizeValue.frame = frame;
	// Size label.
	itemSize = [sizeLabel.text sizeWithFont:sizeLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX -= (itemSize.width + INNER_MARGIN_X);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	sizeLabel.frame = frame;

	// Current title.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	itemSize = CGSizeMake(screenBounds.size.width, 18.0);
	frame = CGRectMake(0.0, posY, itemSize.width, itemSize.height);
	currentTitle.frame = frame;

	// Current rating label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [currentRatingsLabel.text sizeWithFont:currentRatingsLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	currentRatingsLabel.frame = frame;
	// Current rating view.
	posX += (itemSize.width + INNER_MARGIN_X);
	if (appDetails.ratingCountCurrent > 0)
	{
		CGFloat realRatingWidth = (currentRatingsView.rating * kStarWidth) + ((ceilf(currentRatingsView.rating)-1.0) * kStarMargin);
		itemSize = CGSizeMake(realRatingWidth, kRatingHeight);
	}
	else
	{
		itemSize = CGSizeZero;
		posX -= MARGIN_X;
	}
	frame = CGRectMake(posX, posY, kRatingWidth, kRatingHeight);
	currentRatingsView.frame = frame;
	// Current rating value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [currentRatingsValue.text sizeWithFont:currentRatingsValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	currentRatingsValue.frame = frame;

	// Current reviews label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [currentReviewsLabel.text sizeWithFont:currentReviewsLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	currentReviewsLabel.frame = frame;
	// Current reviews value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [currentReviewsValue.text sizeWithFont:currentReviewsValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	currentReviewsValue.frame = frame;

	// All title.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = CGSizeMake(screenBounds.size.width, 18.0);
	frame = CGRectMake(0.0, posY, itemSize.width, itemSize.height);
	allTitle.frame = frame;

	// All rating label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [allRatingsLabel.text sizeWithFont:allRatingsLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	allRatingsLabel.frame = frame;
	// All rating view.
	posX += (itemSize.width + INNER_MARGIN_X);
	if (appDetails.ratingCountAll > 0)
	{
		CGFloat realRatingWidth = (allRatingsView.rating * kStarWidth) + ((ceilf(allRatingsView.rating)-1.0) * kStarMargin);
		itemSize = CGSizeMake(realRatingWidth, kRatingHeight);
	}
	else
	{
		itemSize = CGSizeZero;
		posX -= MARGIN_X;
	}
	frame = CGRectMake(posX, posY, kRatingWidth, kRatingHeight);
	allRatingsView.frame = frame;
	// All rating value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [allRatingsValue.text sizeWithFont:allRatingsValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	allRatingsValue.frame = frame;

	// All reviews label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [allReviewsLabel.text sizeWithFont:allReviewsLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	allReviewsLabel.frame = frame;
	// All reviews value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [allReviewsValue.text sizeWithFont:allReviewsValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	allReviewsValue.frame = frame;
}

- (void)setAppDetails:(PSAppStoreApplicationDetails *)inDetails
{
	[inDetails retain];
	[appDetails release];
	appDetails = inDetails;

	if (appDetails)
	{
		PSAppStoreApplication *theApp = [[PSAppReviewsStore sharedInstance] applicationForIdentifier:appDetails.appIdentifier];
		if (theApp.name)
			appName.text = theApp.name;
		else
			appName.text = theApp.appIdentifier;
		if (theApp.company)
			appCompany.text = theApp.company;
		else
			appCompany.text = @"Waiting for first update";
		priceValue.text = (appDetails.localPrice ? appDetails.localPrice : @"Unknown");
		dateValue.text = (appDetails.released ? appDetails.released : @"Unknown");

		currentRatingsView.rating = appDetails.ratingCurrent;
		if (appDetails.ratingCountCurrent > 0)
			currentRatingsValue.text = [NSString stringWithFormat:@"in %d rating%@", appDetails.ratingCountCurrent, (appDetails.ratingCountCurrent==1?@"":@"s")];
		else
			currentRatingsValue.text = @"No ratings";

		if (appDetails.reviewCountCurrent > 0)
			currentReviewsValue.text = [NSString stringWithFormat:@"%d review%@", appDetails.reviewCountCurrent, (appDetails.reviewCountCurrent==1?@"":@"s")];
		else
			currentReviewsValue.text = @"No reviews";

		allRatingsView.rating = appDetails.ratingAll;
		if (appDetails.ratingCountAll > 0)
			allRatingsValue.text = [NSString stringWithFormat:@"in %d rating%@", appDetails.ratingCountAll, (appDetails.ratingCountAll==1?@"":@"s")];
		else
			allRatingsValue.text = @"No ratings";

		if (appDetails.reviewCountAll > 0)
			allReviewsValue.text = [NSString stringWithFormat:@"%d review%@", appDetails.reviewCountAll, (appDetails.reviewCountAll==1?@"":@"s")];
		else
			allReviewsValue.text = @"No reviews";

		versionValue.text = (appDetails.appVersion ? appDetails.appVersion : @"Unknown");
		sizeValue.text = (appDetails.appSize ? appDetails.appSize : @"Unknown");
	}
	else
	{
		appName.text = @"";
		appCompany.text = @"";
		priceValue.text = @"";
		dateValue.text = @"";
		currentRatingsView.rating = 0.0;
		currentRatingsValue.text = @"";
		currentReviewsValue.text = @"";
		allRatingsView.rating = 0.0;
		allRatingsValue.text = @"";
		allReviewsValue.text = @"";
		versionValue.text = @"";
		sizeValue.text = @"";
	}

	[self setNeedsLayout];
	[self setNeedsDisplay];
}

@end
