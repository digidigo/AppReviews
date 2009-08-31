//
//  PSAppStoreDetailsViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreDetailsViewController.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreRatingsCountTableCell.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSHorizontalBarView.h"


typedef enum
{
	PSAppStoreDetailsRatingsSection,
	PSAppStoreDetailsSectionCount
} PSAppStoreDetailsSection;

typedef enum
{
	PSAppStoreDetailsRatingsFiveStarsRow,
	PSAppStoreDetailsRatingsFourStarsRow,
	PSAppStoreDetailsRatingsThreeStarsRow,
	PSAppStoreDetailsRatingsTwoStarsRow,
	PSAppStoreDetailsRatingsOneStarRow,
	PSAppStoreDetailsRatingsRowCount
} PSAppStoreDetailsRatingsRow;


@implementation PSAppStoreDetailsViewController

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
    return PSAppStoreDetailsSectionCount;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case PSAppStoreDetailsRatingsSection:
			return PSAppStoreDetailsRatingsRowCount;
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
		case PSAppStoreDetailsRatingsSection:
		{
			// Obtain the cell.
			PSAppStoreRatingsCountTableCell *rcCell = (PSAppStoreRatingsCountTableCell *) [tableView dequeueReusableCellWithIdentifier:kRatingsCountCellIdentifier];
			if (rcCell == nil)
			{
				rcCell = [[[PSAppStoreRatingsCountTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRatingsCountCellIdentifier] autorelease];
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
				case PSAppStoreDetailsRatingsFiveStarsRow:
					rcCell.ratingView.rating = 5.0;
					rcCell.countView.count = ratingCountFiveStars;
					break;
				case PSAppStoreDetailsRatingsFourStarsRow:
					rcCell.ratingView.rating = 4.0;
					rcCell.countView.count = ratingCountFourStars;
					break;
				case PSAppStoreDetailsRatingsThreeStarsRow:
					rcCell.ratingView.rating = 3.0;
					rcCell.countView.count = ratingCountThreeStars;
					break;
				case PSAppStoreDetailsRatingsTwoStarsRow:
					rcCell.ratingView.rating = 2.0;
					rcCell.countView.count = ratingCountTwoStars;
					break;
				case PSAppStoreDetailsRatingsOneStarRow:
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

