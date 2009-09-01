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

#import "ARAppStoreDetailsViewController.h"
#import "ARAppStoreApplicationDetails.h"
#import "ARAppStoreRatingsCountTableCell.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "ARHorizontalBarView.h"


typedef enum
{
	ARAppStoreDetailsRatingsSection,
	ARAppStoreDetailsSectionCount
} ARAppStoreDetailsSection;

typedef enum
{
	ARAppStoreDetailsRatingsFiveStarsRow,
	ARAppStoreDetailsRatingsFourStarsRow,
	ARAppStoreDetailsRatingsThreeStarsRow,
	ARAppStoreDetailsRatingsTwoStarsRow,
	ARAppStoreDetailsRatingsOneStarRow,
	ARAppStoreDetailsRatingsRowCount
} ARAppStoreDetailsRatingsRow;


@implementation ARAppStoreDetailsViewController

@synthesize appStoreDetails, useCurrentVersion;

- (void)dealloc
{
	[appStoreDetails release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (useCurrentVersion)
		self.title = @"Current Version";
	else
		self.title = @"All Versions";

	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ARAppStoreDetailsSectionCount;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case ARAppStoreDetailsRatingsSection:
			return ARAppStoreDetailsRatingsRowCount;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kRatingsCountCellIdentifier = @"RatingsCountCell";
    UITableViewCell *cell = nil;

	switch (indexPath.section)
	{
		case ARAppStoreDetailsRatingsSection:
		{
			// Obtain the cell.
			ARAppStoreRatingsCountTableCell *rcCell = (ARAppStoreRatingsCountTableCell *) [tableView dequeueReusableCellWithIdentifier:kRatingsCountCellIdentifier];
			if (rcCell == nil)
			{
				rcCell = [[[ARAppStoreRatingsCountTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRatingsCountCellIdentifier] autorelease];
				[rcCell.barView setBarRed:27.0/255.0 green:58.0/255.0 blue:95.0/255.0 alpha:1.0];
			}

			// Configure the cell.
			NSUInteger ratingCountFiveStars, ratingCountFourStars, ratingCountThreeStars, ratingCountTwoStars, ratingCountOneStar;
			if (useCurrentVersion)
			{
				ratingCountFiveStars = appStoreDetails.ratingCountCurrent5Stars;
				ratingCountFourStars = appStoreDetails.ratingCountCurrent4Stars;
				ratingCountThreeStars = appStoreDetails.ratingCountCurrent3Stars;
				ratingCountTwoStars = appStoreDetails.ratingCountCurrent2Stars;
				ratingCountOneStar = appStoreDetails.ratingCountCurrent1Star;
			}
			else
			{
				ratingCountFiveStars = appStoreDetails.ratingCountAll5Stars;
				ratingCountFourStars = appStoreDetails.ratingCountAll4Stars;
				ratingCountThreeStars = appStoreDetails.ratingCountAll3Stars;
				ratingCountTwoStars = appStoreDetails.ratingCountAll2Stars;
				ratingCountOneStar = appStoreDetails.ratingCountAll1Star;
			}

			NSUInteger maxCount = MAX(MAX(MAX(MAX(ratingCountOneStar,ratingCountTwoStars),ratingCountThreeStars),ratingCountFourStars),ratingCountFiveStars);
			switch (indexPath.row)
			{
				case ARAppStoreDetailsRatingsFiveStarsRow:
					rcCell.ratingView.rating = 5.0;
					rcCell.countView.count = ratingCountFiveStars;
					break;
				case ARAppStoreDetailsRatingsFourStarsRow:
					rcCell.ratingView.rating = 4.0;
					rcCell.countView.count = ratingCountFourStars;
					break;
				case ARAppStoreDetailsRatingsThreeStarsRow:
					rcCell.ratingView.rating = 3.0;
					rcCell.countView.count = ratingCountThreeStars;
					break;
				case ARAppStoreDetailsRatingsTwoStarsRow:
					rcCell.ratingView.rating = 2.0;
					rcCell.countView.count = ratingCountTwoStars;
					break;
				case ARAppStoreDetailsRatingsOneStarRow:
					rcCell.ratingView.rating = 1.0;
					rcCell.countView.count = ratingCountOneStar;
					break;
			}
			rcCell.barView.barValue = (double)rcCell.countView.count / (double)maxCount;

			cell = rcCell;
			rcCell.accessoryType = UITableViewCellAccessoryNone;
			rcCell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		}
	}

    return cell;
}

@end

