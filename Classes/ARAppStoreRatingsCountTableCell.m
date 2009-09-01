//
//	Copyright (c) 2008-2009, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
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
//	* Neither the name of AppReviews nor the names of its contributors may be used
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

#import "ARAppStoreRatingsCountTableCell.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "ARHorizontalBarView.h"


#define kRatingsCountBarWidth	kRatingWidth
#define kRatingsCountBarHeight	16.0


@implementation ARAppStoreRatingsCountTableCell

@synthesize ratingView, countView, barView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
	{
        // Initialization code here.
		ratingView = [[PSRatingView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:ratingView];

		countView = [[PSCountView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:countView];

		CGRect countBounds = [PSCountView boundsForCount:[countView count] usingFontSize:countView.fontSize];
		barView = [[ARHorizontalBarView alloc] initWithFrame:CGRectMake(0, 0, kRatingsCountBarWidth, countBounds.size.height)];
		[self.contentView addSubview:barView];
    }
    return self;
}

- (void)dealloc
{
	[ratingView release];
	[countView release];
	[barView release];
    [super dealloc];
}

- (void)layoutSubviews
{
#define MARGIN_X 5
#define MARGIN_Y 5
#define INNER_MARGIN_X 10

    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;

	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	CGRect countBounds = [PSCountView boundsForCount:[countView count] usingFontSize:countView.fontSize];

	// Position rating view.
	frame = CGRectMake(boundsX + MARGIN_X, floorf(contentRect.origin.y + ((contentRect.size.height - kRatingHeight) / 2.0)), kRatingWidth, kRatingHeight);
	ratingView.frame = frame;

	// Position count.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (countBounds.size.width + INNER_MARGIN_X + kRatingsCountBarWidth + MARGIN_X), floorf(contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0)), countBounds.size.width, countBounds.size.height);
	countView.frame = frame;

	// Position bar.
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - (kRatingsCountBarWidth + MARGIN_X), floorf(contentRect.origin.y + ((contentRect.size.height - countBounds.size.height) / 2.0)), kRatingsCountBarWidth, countBounds.size.height);
	barView.frame = frame;
}

@end
