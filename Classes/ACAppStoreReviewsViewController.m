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

#import "ACAppReviewsStore.h"
#import "ACAppStoreReviewsViewController.h"
#import "ACAppStoreDetailsViewController.h"
#import "ACAppStoreApplicationDetails.h"
#import "ACAppStoreApplicationReview.h"
#import "ACAppStoreApplication.h"
#import "ACAppStoreUpdateOperation.h"
#import "ACAppStore.h"
#import "ACAppStoreReviewsHeaderTableCell.h"
#import "ACAppStoreReviewsSummaryTableCell.h"
#import "ACAppStoreReviewTableCell.h"
#import "PSRatingView.h"
#import "PSLog.h"
#import "NSDate+ACNSDateAdditions.h"
#import "AppCriticsAppDelegate.h"


static UIColor *sPrimaryRowColor = nil;
static UIColor *sAlternateRowColor = nil;


typedef enum
{
	ACAppStoreReviewsHeaderSection,
	ACAppStoreReviewsCurrentSection,
	ACAppStoreReviewsAllSection,
	ACAppStoreReviewsReviewsSection,
	ACAppStoreReviewsSectionCount
} ACAppStoreReviewsSection;


@interface ACAppStoreReviewsViewController ()

@property (nonatomic, retain) ACAppStoreDetailsViewController *appStoreDetailsViewController;
- (void)updateViewForState;

@end


@implementation ACAppStoreReviewsViewController

@synthesize updateButtonItem, activitySpinnerItem, activitySpinner, appStoreDetails, userReviews, appStoreDetailsViewController;

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

		// Set the back button title.
		self.navigationItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
		// Create the update button & spinner.
		self.updateButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateDetails:)] autorelease];
		self.activitySpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		self.activitySpinner.hidesWhenStopped = NO;
		self.activitySpinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
		UIView *spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 34.0, 29.0)];
		[spinnerView addSubview:self.activitySpinner];
		self.activitySpinner.center = spinnerView.center;
		self.activitySpinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:spinnerView] autorelease];
		[spinnerView release];

		self.appStoreDetails = nil;
		self.userReviews = nil;
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[updateButtonItem release];
	[activitySpinnerItem release];
	[activitySpinner release];
	[appStoreDetails release];
	[userReviews release];
	[appStoreDetailsViewController release];
    [super dealloc];
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	self.appStoreDetailsViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSAssert(appStoreDetails, @"appStoreDetails must be set");

    [super viewWillAppear:animated];
	ACAppStoreApplication *app = [[ACAppReviewsStore sharedInstance] applicationForIdentifier:appStoreDetails.appIdentifier];
	ACAppStore *store = [[ACAppReviewsStore sharedInstance] storeForIdentifier:appStoreDetails.storeIdentifier];
	self.userReviews = [[ACAppReviewsStore sharedInstance] reviewsForApplication:app inStore:store];
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

	// Display the update button or activity spinner.
	[self updateViewForState];

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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdateDidStart:) name:kACAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdateDidFail:) name:kACAppStoreUpdateOperationDidFailNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdateDidFinish:) name:kACAppStoreUpdateOperationDidFinishNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kACAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kACAppStoreUpdateOperationDidFailNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kACAppStoreUpdateOperationDidFinishNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	// Release cached data while offscreen.
	self.userReviews = nil;
}

- (void)updateViewForState
{
	// Display the update button or activity spinner.
	switch (appStoreDetails.state)
	{
		case ACAppStoreStatePending:
		{
			[self.activitySpinner stopAnimating];
			self.navigationItem.rightBarButtonItem = self.activitySpinnerItem;
			break;
		}
		case ACAppStoreStateProcessing:
		{
			[self.activitySpinner startAnimating];
			self.navigationItem.rightBarButtonItem = self.activitySpinnerItem;
			break;
		}
		default:
		{
			[self.activitySpinner stopAnimating];
			self.navigationItem.rightBarButtonItem = self.updateButtonItem;
			break;
		}
	}
}

- (void)setAppStoreReviews:(ACAppStoreApplicationDetails *)inDetails
{
	[inDetails retain];
	[appStoreDetails release];
	appStoreDetails = inDetails;

	self.userReviews = nil;
}

- (void)updateDetails:(id)sender
{
	ACAppStoreApplication *appStoreApplication = [[ACAppReviewsStore sharedInstance] applicationForIdentifier:appStoreDetails.appIdentifier];
	// User tapped the Update button - queue up the download operation.

	// First cancel all current/pending operations for this app/store.
	[appStoreApplication suspendAllOperations];
	[appStoreApplication cancelOperationsForApplicationDetails:(ACAppStoreApplicationDetails *)appStoreDetails];

	// Add operation to the queue for processing.
	appStoreDetails.state = ACAppStoreStatePending;
	ACAppStoreUpdateOperation *op = [[ACAppStoreUpdateOperation alloc] initWithApplicationDetails:appStoreDetails];
	[op setQueuePriority:NSOperationQueuePriorityHigh];
	[appStoreApplication addUpdateOperation:op];
	[op release];

	// Update view for new state.
	[self updateViewForState];

	// Start processing.
	[appStoreApplication resumeAllOperations];
}

// Called on main thread after Start.
- (void)appStoreReviewsUpdateDidStart:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	ACAppStoreApplicationDetails *lastStoreProcessed = (ACAppStoreApplicationDetails *) [notification object];

	// Only pay attention to this notification if it is for our current application AND store.
	if ([lastStoreProcessed.appIdentifier isEqualToString:appStoreDetails.appIdentifier] &&
		[lastStoreProcessed.storeIdentifier isEqualToString:appStoreDetails.storeIdentifier])
	{
		// Update view to reflect current download state.
		[self updateViewForState];
	}
}

// Called on main thread after Fail.
- (void)appStoreReviewsUpdateDidFail:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	ACAppStoreApplicationDetails *lastStoreProcessed = (ACAppStoreApplicationDetails *) [notification object];

	// Only pay attention to this notification if it is for our current application AND store.
	if ([lastStoreProcessed.appIdentifier isEqualToString:appStoreDetails.appIdentifier] &&
		[lastStoreProcessed.storeIdentifier isEqualToString:appStoreDetails.storeIdentifier])
	{
		// Update view to reflect current download state.
		[self updateViewForState];
	}
}

// Called on main thread after Finish.
- (void)appStoreReviewsUpdateDidFinish:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	ACAppStoreApplicationDetails *lastStoreProcessed = (ACAppStoreApplicationDetails *) [notification object];

	// Only pay attention to this notification if it is for our current application AND store.
	if ([lastStoreProcessed.appIdentifier isEqualToString:appStoreDetails.appIdentifier] &&
		[lastStoreProcessed.storeIdentifier isEqualToString:appStoreDetails.storeIdentifier])
	{
		// Update table to show reviews that were just completed.
		[self viewWillAppear:YES];
	}
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 0.0;

	switch (indexPath.section)
	{
		case ACAppStoreReviewsHeaderSection:
			result = 88.0;
			break;
		case ACAppStoreReviewsCurrentSection:
			result = 40.0;
			break;
		case ACAppStoreReviewsAllSection:
			result = 40.0;
			break;
		case ACAppStoreReviewsReviewsSection:
		{
			NSUInteger reviewIndex = indexPath.row;
			ACAppStoreApplicationReview *review = (ACAppStoreApplicationReview *) [userReviews objectAtIndex:reviewIndex];
			if (review)
			{
				[review hydrate];
				result = [ACAppStoreReviewTableCell tableView:tableView heightForCellWithReview:review];
			}
			break;
		}
	}

	PSLog(@"%@ returning %g", indexPath, result);
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case ACAppStoreReviewsCurrentSection:
		case ACAppStoreReviewsAllSection:
		{
			ACAppStoreReviewsSummaryTableCell *summaryCell = (ACAppStoreReviewsSummaryTableCell *) [tableView cellForRowAtIndexPath:indexPath];
			if (summaryCell.ratingsCount > 0)
			{
				// Lazily create details view controller.
				if (self.appStoreDetailsViewController == nil)
				{
					ACAppStoreDetailsViewController *viewController = [[ACAppStoreDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
					self.appStoreDetailsViewController = viewController;
					[viewController release];
				}
				self.appStoreDetailsViewController.appStoreDetails = appStoreDetails;
				self.appStoreDetailsViewController.navigationItem.prompt = self.navigationItem.prompt;
				self.appStoreDetailsViewController.useCurrentVersion = (indexPath.section == ACAppStoreReviewsCurrentSection);
				[self.navigationController pushViewController:self.appStoreDetailsViewController animated:YES];
			}
			break;
		}
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 	ACAppStoreReviewsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case ACAppStoreReviewsHeaderSection:
			// Always have a header row.
			return 1;
		case ACAppStoreReviewsCurrentSection:
			// Always have a Current row.
			return 1;
		case ACAppStoreReviewsAllSection:
			// Always have an All row.
			return 1;
		case ACAppStoreReviewsReviewsSection:
			return [userReviews count];
	}

	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case ACAppStoreReviewsCurrentSection:
			return @"Current Version";
		case ACAppStoreReviewsAllSection:
			return @"All Versions";
		case ACAppStoreReviewsReviewsSection:
			return @"Reviews";
	}

	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HeaderCellIdentifier = @"HeaderCell";
    static NSString *SummaryCellIdentifier = @"SummaryCell";
    static NSString *ReviewCellIdentifier = @"ReviewCell";

	UITableViewCell *cell = nil;

	switch (indexPath.section)
	{
		case ACAppStoreReviewsHeaderSection:
		{
			// Header row.

			// Obtain the cell.
			ACAppStoreReviewsHeaderTableCell *headerCell = (ACAppStoreReviewsHeaderTableCell *) [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
			if (headerCell == nil)
			{
				headerCell = [[[ACAppStoreReviewsHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier] autorelease];
			}

			// Configure the cell.
			headerCell.appDetails = self.appStoreDetails;
			cell = headerCell;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		}
		case ACAppStoreReviewsCurrentSection:
		{
			// Obtain the cell.
			ACAppStoreReviewsSummaryTableCell *summaryCell = (ACAppStoreReviewsSummaryTableCell *) [tableView dequeueReusableCellWithIdentifier:SummaryCellIdentifier];
			if (summaryCell == nil)
			{
				summaryCell = [[[ACAppStoreReviewsSummaryTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SummaryCellIdentifier] autorelease];
			}

			// Configure the cell.
			summaryCell.ratingsCount = self.appStoreDetails.ratingCountCurrent;
			summaryCell.reviewsCount = self.appStoreDetails.reviewCountCurrent;
			summaryCell.averageRating = self.appStoreDetails.ratingCurrent;
			[summaryCell setNeedsLayout];

			cell = summaryCell;
			if (summaryCell.ratingsCount > 0)
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
			else
			{
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		}
		case ACAppStoreReviewsAllSection:
		{
			// Obtain the cell.
			ACAppStoreReviewsSummaryTableCell *summaryCell = (ACAppStoreReviewsSummaryTableCell *) [tableView dequeueReusableCellWithIdentifier:SummaryCellIdentifier];
			if (summaryCell == nil)
			{
				summaryCell = [[[ACAppStoreReviewsSummaryTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SummaryCellIdentifier] autorelease];
			}
			// Configure the cell.
			summaryCell.averageRating = self.appStoreDetails.ratingAll;
			summaryCell.ratingsCount = self.appStoreDetails.ratingCountAll;
			summaryCell.reviewsCount = self.appStoreDetails.reviewCountAll;

			cell = summaryCell;
			if (summaryCell.ratingsCount > 0)
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
			else
			{
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		}
		case ACAppStoreReviewsReviewsSection:
		{
			NSUInteger reviewIndex = indexPath.row;
			// Obtain the cell.
			ACAppStoreReviewTableCell *reviewCell = (ACAppStoreReviewTableCell *) [tableView dequeueReusableCellWithIdentifier:ReviewCellIdentifier];
			if (reviewCell == nil)
			{
				reviewCell = [[[ACAppStoreReviewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReviewCellIdentifier] autorelease];
			}

			// Configure the cell.
			ACAppStoreApplicationReview *review = (ACAppStoreApplicationReview *) [userReviews objectAtIndex:reviewIndex];
			[review hydrate];
			reviewCell.review = review;

			// Use alternate colours for rows.
			if (reviewIndex % 2 == 0)
			{
				// Even row.
				reviewCell.contentView.backgroundColor = sPrimaryRowColor;
				reviewCell.detailLabel.backgroundColor = sPrimaryRowColor;
			}
			else
			{
				// Even row.
				reviewCell.contentView.backgroundColor = sAlternateRowColor;
				reviewCell.detailLabel.backgroundColor = sAlternateRowColor;
			}
			cell = reviewCell;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		}
	}

    return cell;
}

@end

