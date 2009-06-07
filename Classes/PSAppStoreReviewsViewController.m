//
//  PSAppStoreReviewsViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppReviewsStore.h"
#import "PSAppStoreReviewsViewController.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreApplicationReview.h"
#import "PSAppStore.h"
#import "PSAppStoreReviewsHeaderTableCell.h"
#import "PSAppStoreReviewTableCell.h"
#import "PSRatingView.h"
#import "PSLog.h"
#import "NSDate+PSNSDateAdditions.h"
#import "AppCriticsAppDelegate.h"


static UIColor *sPrimaryRowColor = nil;
static UIColor *sAlternateRowColor = nil;


@implementation PSAppStoreReviewsViewController

@synthesize appStoreDetails, userReviews;

+ (void)initialize
{
	sPrimaryRowColor = [[UIColor whiteColor] retain];
	sAlternateRowColor = [[UIColor colorWithRed:236.0/255.0 green:243.0/255.0 blue:255.0/255.0 alpha:1.0] retain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.title = @"Reviews";
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

		self.appStoreDetails = nil;
		self.userReviews = nil;
    }
    return self;
}

- (void)dealloc
{
	[appStoreDetails release];
	[userReviews release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSAssert(appStoreDetails, @"appStoreDetails must be set");

    [super viewWillAppear:animated];
	PSAppStoreApplication *app = [[PSAppReviewsStore sharedInstance] applicationForIdentifier:appStoreDetails.appIdentifier];
	PSAppStore *store = [[PSAppReviewsStore sharedInstance] storeForIdentifier:appStoreDetails.storeIdentifier];
	self.userReviews = [[PSAppReviewsStore sharedInstance] reviewsForApplication:app inStore:store];
	self.title = store.name;
	[self.tableView reloadData];

	// Display the last-updated time as a prompt.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setCalendar:[NSCalendar currentCalendar]];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *timeValue = [dateFormatter stringFromDate:appStoreDetails.lastUpdated];
	[dateFormatter release];
	NSString *lastUpdated = @"Never";
	// Has this app/store ever been updated?
	if ([appStoreDetails.lastUpdated compare:[NSDate distantPast]] != NSOrderedSame)
	{
		lastUpdated = [NSString stringWithFormat:@"%@ at %@", [appStoreDetails.lastUpdated friendlyMediumDateStringAllowingWords:YES], timeValue];
	}
	self.navigationItem.prompt = [NSString stringWithFormat:@"Last updated: %@", lastUpdated];

	if ([self.tableView numberOfRowsInSection:0] > 0)
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	// See if the sortOrder preference has changed since these reviews were downloaded.
	if ([userReviews count] > 0)
	{
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"] != appStoreDetails.lastSortOrder)
		{
			// Sort order preference has changed since reviews were downloaded.
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:@"The Sort Order setting has been changed since these reviews were downloaded. Reviews must be updated for the new setting to take effect." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	// Release cached data while offscreen.
	self.userReviews = nil;
}

- (void)setAppStoreReviews:(PSAppStoreApplicationDetails *)inDetails
{
	[inDetails retain];
	[appStoreDetails release];
	appStoreDetails = inDetails;

	self.userReviews = nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 0.0;
	if (indexPath.row == 0)
	{
		// Header row.
		result = 194.0;
	}
	else if (indexPath.row > 0)
	{
		NSUInteger reviewIndex = indexPath.row - 1;
		PSAppStoreApplicationReview *review = (PSAppStoreApplicationReview *) [userReviews objectAtIndex:reviewIndex];
		if (review)
		{
			[review hydrate];
			result = [PSAppStoreReviewTableCell tableView:tableView heightForCellWithReview:review];
		}
	}

	PSLog(@"%@ returning %g", indexPath, result);
	return result;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Always have a header row.
	NSInteger rowCount = 1;

	if (userReviews)
		rowCount += [userReviews count];

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HeaderCellIdentifier = @"HeaderCell";
    static NSString *ReviewCellIdentifier = @"ReviewCell";

	UITableViewCell *cell = nil;

	if (indexPath.row == 0)
	{
		// Header row.

		// Obtain the cell;
		PSAppStoreReviewsHeaderTableCell *headerCell = (PSAppStoreReviewsHeaderTableCell *) [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
		if (headerCell == nil)
		{
			headerCell = [[[PSAppStoreReviewsHeaderTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:HeaderCellIdentifier] autorelease];
		}
		// Configure the cell
		headerCell.appDetails = self.appStoreDetails;

		cell = headerCell;
	}
	else if (indexPath.row > 0)
	{
		NSUInteger reviewIndex = indexPath.row - 1;
		PSAppStoreReviewTableCell *reviewCell = (PSAppStoreReviewTableCell *) [tableView dequeueReusableCellWithIdentifier:ReviewCellIdentifier];
		if (reviewCell == nil)
		{
			reviewCell = [[[PSAppStoreReviewTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:ReviewCellIdentifier] autorelease];
		}
		// Configure the cell
		PSAppStoreApplicationReview *review = (PSAppStoreApplicationReview *) [userReviews objectAtIndex:reviewIndex];
		[review hydrate];
		reviewCell.review = review;

		// Use alternate colours for rows.
		if (reviewIndex % 2 == 0)
		{
			// Even row.
			reviewCell.contentView.backgroundColor = sPrimaryRowColor;
		}
		else
		{
			// Even row.
			reviewCell.contentView.backgroundColor = sAlternateRowColor;
		}
		cell = reviewCell;
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

@end

