//
//  PSTitleValueTableCell.m
//  PSCommon
//
//  Created by Charles Gamble on 21/03/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSTitleValueTableCell.h"
#import "UIColor+MoreColors.h"


/**
 * Cell identifier for this custom cell.
 */
NSString *kPSTitleValueTableCellID = @"PSTitleValueTableCellID";


/**
 * Subclass of UITableViewCell which displays a title and a value.
 * Maximum title width can be set using the titleWidth property.
 */
@implementation PSTitleValueTableCell

@synthesize titleLabel, valueLabel, titleWidth;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
        // Initialization code here.
		titleWidth = 160;

		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.opaque = NO;
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		[self.contentView addSubview:titleLabel];
		
		valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		valueLabel.textAlignment = UITextAlignmentRight;
		valueLabel.backgroundColor = [UIColor clearColor];
		valueLabel.opaque = NO;
		valueLabel.textColor = [UIColor tableCellTextBlue];
		valueLabel.highlightedTextColor = [UIColor whiteColor];
		valueLabel.font = [UIFont systemFontOfSize:16];
		[self.contentView addSubview:valueLabel];		
    }
    return self;
}

- (void)dealloc
{
	[titleLabel release];
	[valueLabel release];
    [super dealloc];
}

- (void)layoutSubviews
{
#define kMarginX 10
#define kMarginY 5
	
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat labelHeight = contentRect.size.height - (2 * kMarginY);
	CGRect frame;
	
	frame = CGRectMake(boundsX + kMarginX, kMarginY, titleWidth, labelHeight);
	titleLabel.frame = frame;
	
	frame = CGRectMake(boundsX + kMarginX + titleWidth, kMarginY, contentRect.size.width-(titleWidth+(2*kMarginX)), labelHeight);
	valueLabel.frame = frame;
}

@end
