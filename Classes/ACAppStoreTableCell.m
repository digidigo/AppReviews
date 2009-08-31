//
//	Copyright (c) 2008-2009, AppCritics
//	http://github.com/gambcl/AppCritics
//	http://www.perculasoft.com/appcritics
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppCritics nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ACAppStoreTableCell.h"
#import "PSImageView.h"
#import "PSRatingView.h"
#import "PSCountView.h"


#define	kActivityIndicatorSize 20.0


@implementation ACAppStoreTableCell

@synthesize nameLabel, flagView, ratingView, ratingCountLabel, countView, state, stateSpinnerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
	{
        // Initialization code here.
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.opaque = NO;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:15];
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:nameLabel];

		flagView = [[PSImageView alloc] initWithFrame:CGRectZero];
		flagView.backgroundColor = [UIColor clearColor];
		flagView.opaque = NO;
		[self.contentView addSubview:flagView];

		ratingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:ratingView];

		ratingCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		ratingCountLabel.backgroundColor = [UIColor clearColor];
		ratingCountLabel.opaque = NO;
		ratingCountLabel.textColor = [UIColor blackColor];
		ratingCountLabel.highlightedTextColor = [UIColor colorWithRed:0.55 green:0.6 blue:0.7 alpha:1.0];
		ratingCountLabel.font = [UIFont systemFontOfSize:14.0];
		ratingCountLabel.textAlignment = UITextAlignmentLeft;
		ratingCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:ratingCountLabel];

		countView = [[PSCountView alloc] initWithFrame:CGRectZero];
		countView.fontSize = nameLabel.font.pointSize;
		countView.backgroundColor = [UIColor clearColor];
		countView.opaque = NO;
		[self.contentView addSubview:countView];

		state = ACAppStoreStateDefault;
		stateSpinnerView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		stateSpinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		stateSpinnerView.hidesWhenStopped = NO;
		[self.contentView addSubview:stateSpinnerView];
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
	[stateSpinnerView release];
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

	NSArray *labelArray = [[NSArray alloc] initWithObjects:nameLabel, ratingCountLabel, nil];
	for (UILabel *label in labelArray)
	{
		label.highlighted = selected;
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
	// Position spinner (over count).
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (kActivityIndicatorSize + MARGIN_X), contentRect.origin.y + ((contentRect.size.height - kActivityIndicatorSize) / 2.0), kActivityIndicatorSize, kActivityIndicatorSize);
	stateSpinnerView.frame = frame;

	// Set background colour behind disclosure indicator.
	self.backgroundColor = self.contentView.backgroundColor;
}

- (void)setState:(ACAppStoreState)value
{
	state = value;
	switch (state)
	{
		case ACAppStoreStatePending:
			[stateSpinnerView stopAnimating];
			stateSpinnerView.hidden = NO;
			countView.hidden = YES;
			self.contentView.backgroundColor = [UIColor whiteColor];
			break;
		case ACAppStoreStateProcessing:
			[stateSpinnerView startAnimating];
			stateSpinnerView.hidden = NO;
			countView.hidden = YES;
			self.contentView.backgroundColor = [UIColor whiteColor];
			break;
		case ACAppStoreStateFailed:
			[stateSpinnerView stopAnimating];
			stateSpinnerView.hidden = YES;
			countView.hidden = NO;
			self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1];
			break;
		default:
			[stateSpinnerView stopAnimating];
			stateSpinnerView.hidden = YES;
			countView.hidden = NO;
			self.contentView.backgroundColor = [UIColor whiteColor];
			break;
	}
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

@end
