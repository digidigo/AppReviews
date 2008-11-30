//
//  PSTitleValueCell.m
//  PSCommon
//
//  Created by Charles Gamble on 21/03/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSTitleValueCell.h"


@implementation PSTitleValueCell

@synthesize titleLabel, valueLabel, titleWidth;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
        // Initialization code here.
		titleWidth = 160;

		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.opaque = YES;
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		[self.contentView addSubview:titleLabel];
		
		valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		valueLabel.textAlignment = UITextAlignmentRight;
		valueLabel.backgroundColor = [UIColor whiteColor];
		valueLabel.opaque = YES;
		valueLabel.textColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (self.selectionStyle != UITableViewCellSelectionStyleNone)
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
		
		NSArray *labelArray = [[NSArray alloc] initWithObjects:titleLabel, valueLabel, nil];
		for (UILabel *label in labelArray)
		{
			label.backgroundColor = backgroundColor;
			label.highlighted = selected;
			label.opaque = !selected;
		}
		[labelArray release];
	}
}

- (void)layoutSubviews
{
#define MARGIN_X 10
#define MARGIN_Y 5
	
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat labelHeight = contentRect.size.height - (2 * MARGIN_Y);
	CGRect frame;
	
	frame = CGRectMake(boundsX + MARGIN_X, MARGIN_Y, titleWidth, labelHeight);
	titleLabel.frame = frame;
	
	frame = CGRectMake(boundsX + MARGIN_X + titleWidth, MARGIN_Y, contentRect.size.width-(titleWidth+(2*MARGIN_X)), labelHeight);
	valueLabel.frame = frame;
}

@end
