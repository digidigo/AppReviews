//
//  PSAppStoreApplicationTableCell.m
//  EventHorizon
//
//  Created by Charles Gamble on 14/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreApplicationTableCell.h"
#import "UIColor+MoreColors.h"


@implementation PSAppStoreApplicationTableCell

@synthesize nameLabel, companyLabel;

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
		nameLabel.font = [UIFont boldSystemFontOfSize:19];
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:nameLabel];
		
		companyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		companyLabel.backgroundColor = [UIColor whiteColor];
		companyLabel.opaque = YES;
		companyLabel.textColor = [UIColor tableCellTextBlue];
		companyLabel.highlightedTextColor = [UIColor whiteColor];
		companyLabel.font = [UIFont boldSystemFontOfSize:12];
		companyLabel.textAlignment = UITextAlignmentLeft;
		companyLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:companyLabel];
    }
    return self;
}

- (void)dealloc
{
	[nameLabel release];
	[companyLabel release];
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
	
	NSArray *labelArray = [[NSArray alloc] initWithObjects:nameLabel, companyLabel, nil];
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
#define LOWER_ROW_TOP 26

    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;

	// Position name label.
	frame = CGRectMake(boundsX + MARGIN_X, UPPER_ROW_TOP, contentRect.size.width-(MARGIN_X + MARGIN_X), 20.0);
	nameLabel.frame = frame;

	// Position rating label.
	frame = CGRectMake(boundsX + MARGIN_X, LOWER_ROW_TOP, contentRect.size.width-(MARGIN_X + MARGIN_X), 14.0);
	companyLabel.frame = frame;	
}

@end
