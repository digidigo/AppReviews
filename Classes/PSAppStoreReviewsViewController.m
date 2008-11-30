//
//  PSAppStoreReviewsViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviewsViewController.h"
#import "PSAppStoreReviews.h"
#import "PSAppStoreReview.h"
#import "PSAppStore.h"
#import "PSAppStoreReviewsHeaderTableCell.h"
#import "PSAppStoreReviewTableCell.h"
#import "PSRatingView.h"
#import "NSDate+PSNSDateAdditions.h"
#import "AppCriticsAppDelegate.h"


static UIColor *sPrimaryRowColor = nil;
static UIColor *sAlternateRowColor = nil;


@implementation PSAppStoreReviewsViewController

@synthesize appStoreReviews, userReviews;

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
		
		self.appStoreReviews = nil;
		self.userReviews = nil;
    }
    return self;
}

- (void)dealloc
{
	[appStoreReviews release];
	[userReviews release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSAssert(appStoreReviews, @"appStoreReviews must be set");
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	// Load reviews lazily for this app/store.
	if (appStoreReviews.reviews == nil)
		[appStoreReviews loadReviews];
	
	if (appStoreReviews.reviews)
		self.userReviews = [NSArray arrayWithArray:appStoreReviews.reviews];
	else
		self.userReviews = [NSArray array];

    [super viewWillAppear:animated];
	PSAppStore *store = [appDelegate storeForId:appStoreReviews.storeId];
	self.title = store.name;
	[self.tableView reloadData];
	
	// Display the last-updated time as a prompt.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setCalendar:[NSCalendar currentCalendar]];			
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *timeValue = [dateFormatter stringFromDate:appStoreReviews.lastUpdated];
	[dateFormatter release];
	NSString *lastUpdated = @"Never";
	// Has this app/store ever been updated?
	if ([appStoreReviews.lastUpdated compare:[NSDate distantPast]] != NSOrderedSame)
	{
		lastUpdated = [NSString stringWithFormat:@"%@ at %@", [appStoreReviews.lastUpdated friendlyMediumDateStringAllowingWords:YES], timeValue];
	}
	self.navigationItem.prompt = [NSString stringWithFormat:@"Last updated: %@", lastUpdated];

	if ([self.tableView numberOfRowsInSection:0] > 0)
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];	
}

- (void)viewDidAppear:(BOOL)animated
{
	// See if the sortOrder preference has changed since these reviews were downloaded.
	if ([userReviews count] > 0)
	{
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"] != appStoreReviews.lastSortOrder)
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
	// Release cached data while offscreen.
	self.userReviews = nil;
}

- (void)setAppStoreReviews:(PSAppStoreReviews *)inReviews
{
	[inReviews retain];
	[appStoreReviews release];
	appStoreReviews = inReviews;
	
	self.userReviews = nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		// Header row.
		return 108.0;
	}
	else if (indexPath.row > 0)
	{
		NSUInteger reviewIndex = indexPath.row - 1;
		PSAppStoreReview *review = (PSAppStoreReview *) [userReviews objectAtIndex:reviewIndex];
		if (review)
			return [PSAppStoreReviewTableCell tableView:tableView heightForCellWithReview:review];
	}
	
	return 0.0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
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
		headerCell.appReviews = self.appStoreReviews;
		
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
		PSAppStoreReview *review = (PSAppStoreReview *) [userReviews objectAtIndex:reviewIndex];
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
    return cell;
}

@end

