//
//  PSAppStoreReviewsHeaderTableCell.m
//  AppCritics
//
//  Created by Charles Gamble on 21/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviewsHeaderTableCell.h"
#import "PSAppStoreReviews.h"
#import "PSAppStoreApplication.h"
#import "PSRatingView.h"
#import "UIColor+MoreColors.h"
#import "AppCriticsAppDelegate.h"


static UIColor *sLabelColor = nil;
static CGGradientRef sGradient = NULL;


@implementation PSAppStoreReviewsHeaderTableCell

@synthesize appReviews, appCompany, versionLabel, versionValue, sizeLabel, sizeValue, dateLabel, dateValue;
@synthesize priceLabel, priceValue, averageRatingLabel, averageRatingValue, averageRatingView;

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
		
		averageRatingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		averageRatingLabel.backgroundColor = [UIColor clearColor];
		averageRatingLabel.opaque = NO;
		averageRatingLabel.textColor = sLabelColor;
		averageRatingLabel.highlightedTextColor = [UIColor whiteColor];
		averageRatingLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		averageRatingLabel.textAlignment = UITextAlignmentLeft;
		averageRatingLabel.lineBreakMode = UILineBreakModeTailTruncation;
		averageRatingLabel.numberOfLines = 1;
		averageRatingLabel.text = @"Average Rating:";
		[self.contentView addSubview:averageRatingLabel];
		
		averageRatingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:averageRatingView];

		averageRatingValue = [[UILabel alloc] initWithFrame:CGRectZero];
		averageRatingValue.backgroundColor = [UIColor clearColor];
		averageRatingValue.opaque = NO;
		averageRatingValue.textColor = [UIColor blackColor];
		averageRatingValue.highlightedTextColor = [UIColor whiteColor];
		averageRatingValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		averageRatingValue.textAlignment = UITextAlignmentLeft;
		averageRatingValue.lineBreakMode = UILineBreakModeTailTruncation;
		averageRatingValue.numberOfLines = 1;
		[self.contentView addSubview:averageRatingValue];
		
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
		
		self.appReviews = nil;
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
	[averageRatingLabel release];
	[averageRatingValue release];
	[averageRatingView release];
	[appReviews release];
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
	
	// Average rating label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [averageRatingLabel.text sizeWithFont:averageRatingLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	averageRatingLabel.frame = frame;
	// Average rating view.
	posX += (itemSize.width + INNER_MARGIN_X);
	if (appReviews.countTotal > 0)
	{
		CGFloat realRatingWidth = (averageRatingView.rating * kStarWidth) + ((ceilf(averageRatingView.rating)-1.0) * kStarMargin);
		itemSize = CGSizeMake(realRatingWidth, kRatingHeight);
	}
	else
	{
		itemSize = CGSizeZero;
		posX -= MARGIN_X;
	}
	frame = CGRectMake(posX, posY, kRatingWidth, kRatingHeight);
	averageRatingView.frame = frame;
	// Average rating value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [averageRatingValue.text sizeWithFont:averageRatingValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	averageRatingValue.frame = frame;
}

- (void)setAppReviews:(PSAppStoreReviews *)inReviews
{
	[inReviews retain];
	[appReviews release];
	appReviews = inReviews;
	
	if (appReviews)
	{
		AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		PSAppStoreApplication *theApp = [appDelegate applicationForId:appReviews.appId];
		if (theApp.name)
			appName.text = theApp.name;
		else
			appName.text = theApp.appId;
		if (theApp.company)
			appCompany.text = theApp.company;
		else
			appCompany.text = @"Waiting for first update";
		priceValue.text = (appReviews.localPrice ? appReviews.localPrice : @"Unknown");
		dateValue.text = (appReviews.released ? appReviews.released : @"Unknown");
		averageRatingView.rating = appReviews.averageRating;
		if (appReviews.countTotal > 0)
			averageRatingValue.text = [NSString stringWithFormat:@"in %d review%@", appReviews.countTotal, (appReviews.countTotal==1?@"":@"s")];
		else
			averageRatingValue.text = @"No reviews";
		versionValue.text = (appReviews.appVersion ? appReviews.appVersion : @"Unknown");
		sizeValue.text = (appReviews.appSize ? appReviews.appSize : @"Unknown");
	}
	else
	{
		appName.text = @"";
		appCompany.text = @"";
		priceValue.text = @"";
		dateValue.text = @"";
		averageRatingView.rating = 0.0;
		averageRatingValue.text = @"";
		versionValue.text = @"";
		sizeValue.text = @"";
	}
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

@end
