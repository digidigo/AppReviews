//
//  PSAppStoreCountriesViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreCountriesViewController.h"
#import "PSAppStoreReviewsViewController.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "PSAppStoreReviews.h"
#import "AppCriticsAppDelegate.h"
#import "PSProgressBarSheet.h"
#import "PSAppStoreTableCell.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSLog.h"


@interface PSAppStoreCountriesViewController ()

@property (nonatomic, retain) NSMutableArray *enabledStores;
@property (nonatomic, retain) NSMutableArray *displayedStores;
@property (nonatomic, retain) UIBarButtonItem *updateButton;
@property (nonatomic, retain) PSAppStoreReviewsViewController *appStoreReviewsViewController;
@property (nonatomic, retain) PSProgressBarSheet *progressBarSheet;
@property (nonatomic, retain) NSMutableArray *storeIdsProcessed;
@property (nonatomic, retain) NSMutableArray *storeIdsRemaining;

- (void)updateDisplayedStores;
- (void)updateReviews:(PSProgressBarSheet *)inProgressBarSheet;

@end

@implementation PSAppStoreCountriesViewController

@synthesize appStoreApplication, enabledStores, displayedStores, updateButton, appStoreReviewsViewController, progressBarSheet, storeIdsProcessed, storeIdsRemaining;

- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.title = @"Countries";
		self.appStoreReviewsViewController = nil;

		// Add the Update button.
		self.updateButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateAllReviews:)] autorelease];
		self.navigationItem.rightBarButtonItem = self.updateButton;

		// Set the back button title.
		self.navigationItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Countries", @"Countries") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

		self.progressBarSheet = [[[PSProgressBarSheet alloc] initWithTitle:@"Processing App Reviews" parentView:self.view] autorelease];
		self.storeIdsProcessed = [NSMutableArray array];
		self.storeIdsRemaining = [NSMutableArray array];
		self.enabledStores = [NSMutableArray array];
		self.displayedStores = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	// Build up a list of enabled stores.
	[enabledStores removeAllObjects];
	for (PSAppStore *store in appDelegate.appStores)
	{
		if (store.enabled)
		{
			[enabledStores addObject:store];
		}
	}
	
	// Deselect any selected row.
	NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
	if (selectedRow)
		[self.tableView deselectRowAtIndexPath:selectedRow animated:NO];
	
	[self updateDisplayedStores];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[appStoreApplication release];
	[updateButton release];
	[appStoreReviewsViewController release];
	[progressBarSheet release];
	[storeIdsProcessed release];
	[storeIdsRemaining release];
	[enabledStores release];
	[displayedStores release];
    [super dealloc];
}

- (void)setAppStoreApplication:(PSAppStoreApplication *)inAppStoreApplication
{
	[inAppStoreApplication retain];
	[appStoreApplication release];
	appStoreApplication = inAppStoreApplication;
	
	if (appStoreApplication.name)
		self.title = appStoreApplication.name;
	else
		self.title = appStoreApplication.appId;
}

- (void)updateDisplayedStores
{
	// Updates the tableview and takes account of the hideEmptyCountries setting.
	[displayedStores removeAllObjects];
	for (PSAppStore *appStore in enabledStores)
	{
		PSAppStoreReviews *storeReviews = (PSAppStoreReviews *) [appStoreApplication.reviewsByStore objectForKey:appStore.storeId];
		// Only add store if it has reviews OR we are not hiding empty stores.
		if ((storeReviews && storeReviews.countTotal > 0) ||
			([[NSUserDefaults standardUserDefaults] boolForKey:@"hideEmptyCountries"] == NO))
		{
			[displayedStores addObject:appStore];
		}
	}
	
	// Refresh table.
	[self.tableView reloadData];
}

- (void)updateAllReviews:(id)sender
{
	// Hide navbar.
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	// Build array of all storeIds for processing.
	[storeIdsProcessed removeAllObjects];
	[storeIdsRemaining removeAllObjects];
	for (PSAppStore *appStore in enabledStores)
	{
		// Only add this store if it is enabled for this app.
		if (appStore.enabled)
		{
			// Make sure that the "home store" for this is first in the list.
			if ([appStore.storeId isEqualToString:appStoreApplication.defaultStoreId])
				[storeIdsRemaining insertObject:appStore.storeId atIndex:0];
			else
				[storeIdsRemaining addObject:appStore.storeId];
		}
	}
	
	// Show progress sheet.
	[progressBarSheet progressBeginWithMessage:@"Connecting"];
	
	// Start processing first entry in storeIds array.
	[self updateReviews:progressBarSheet];
}

// Always call on main thread.
// Called when a store download/parse has completed, or been cancelled, or failed.
- (void)updateReviews:(PSProgressBarSheet *)inProgressBarSheet
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	if (appDelegate.exiting)
	{
		// Remove modal progress sheet because we are exiting.
		[progressBarSheet progressUpdate:[NSNumber numberWithFloat:1.0f]];
		[progressBarSheet progressEnd];
		// Restore navigation bar.
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	else
	{
		// Update table to show any store's reviews that were just completed.
		[self updateDisplayedStores];
		
		// Fill in missing app details if we have them available in last processed store reviews.
		if ((appStoreApplication.name==nil || appStoreApplication.company==nil) && [storeIdsProcessed count] > 0)
		{
			NSString *lastStoreIdProcessed = [storeIdsProcessed lastObject];
			PSAppStoreReviews *lastStoreProcessed = [appStoreApplication.reviewsByStore objectForKey:lastStoreIdProcessed];
			if (lastStoreProcessed.appName && [lastStoreProcessed.appName length] > 0)
			{
				appStoreApplication.name = lastStoreProcessed.appName;
				self.title = lastStoreProcessed.appName;
			}

			if (lastStoreProcessed.appCompany && [lastStoreProcessed.appCompany length] > 0)
			{
				appStoreApplication.company = lastStoreProcessed.appCompany;
			}
		}

		// See if we still have stores to process.
		if ([storeIdsRemaining count] > 0)
		{
			// We still have stores to process.
			NSString *thisStore = [storeIdsRemaining objectAtIndex:0];
			PSAppStoreReviews *appStoreReviews = [appStoreApplication.reviewsByStore objectForKey:thisStore];
			float progress = ((float)([enabledStores count]-[storeIdsRemaining count])/(float)[enabledStores count]);
			[progressBarSheet progressUpdateMessage:[[appDelegate storeForId:appStoreReviews.storeId] name]];
			[progressBarSheet progressUpdate:[NSNumber numberWithFloat:progress]];
			[appStoreReviews fetchReviews:progressBarSheet];
			[storeIdsProcessed addObject:thisStore];
			[storeIdsRemaining removeObjectAtIndex:0];
		}
		else
		{
			// No more stores to process.
			[progressBarSheet progressUpdate:[NSNumber numberWithFloat:1.0f]];
			[progressBarSheet progressEnd];
			// Restore navigation bar.
			[self.navigationController setNavigationBarHidden:NO animated:YES];
			
			// Check to see if there were errors downloading.
			if ([storeIdsProcessed count] > 0)
			{
				NSMutableArray *failedStoreNames = [[NSMutableArray alloc] init];
				for (NSString *aStoreId in storeIdsProcessed)
				{
					PSAppStoreReviews *storeProcessed = [appStoreApplication.reviewsByStore objectForKey:aStoreId];
					if (storeProcessed.appName==nil && storeProcessed.appCompany==nil)
					{
						// This store failed to download.
						PSAppStore *failedStore = [appDelegate storeForId:aStoreId];
						[failedStoreNames addObject:failedStore.name];
					}
				}
				if ([failedStoreNames count] > 0)
				{
					// We have some failed stores.
					NSString *msg = @"AppCritics could not download reviews from any App Stores. Please check network connection before trying again.";
					if ([failedStoreNames count] != [enabledStores count])
						msg = [NSString stringWithFormat:@"AppCritics could not download reviews from the following stores:\n%@\nPlease check network connection before trying again.", [failedStoreNames componentsJoinedByString:@"\n"]];
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
					[alert show];
					[alert release];
				}
				[failedStoreNames release];
			}
		}
	}
}

- (void)appStoreReviewsUpdated:(NSNotification *)notification
{
	[self performSelectorOnMainThread:@selector(updateReviews:) withObject:progressBarSheet waitUntilDone:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:PSAppStoreReviewsUpdatedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	PSAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	PSAppStoreReviews *storeReviews = (PSAppStoreReviews *) [appStoreApplication.reviewsByStore objectForKey:appStore.storeId];
	if (storeReviews)
	{
		return UITableViewCellAccessoryDisclosureIndicator;
	}
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Display reviews for store.	
	PSAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	PSAppStoreReviews *appStoreReviews = (PSAppStoreReviews *) [appStoreApplication.reviewsByStore objectForKey:appStore.storeId];
	// Lazily create countries view controller.
	if (self.appStoreReviewsViewController == nil)
	{
		PSAppStoreReviewsViewController *viewController = [[PSAppStoreReviewsViewController alloc] initWithStyle:UITableViewStylePlain];
		self.appStoreReviewsViewController = viewController;
		[viewController release];
	}
	self.appStoreReviewsViewController.appStoreReviews = appStoreReviews;
	[self.navigationController pushViewController:self.appStoreReviewsViewController animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayedStores count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"AppStoreCell";
    
    PSAppStoreTableCell *cell = (PSAppStoreTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[PSAppStoreTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	PSAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	cell.nameLabel.text = appStore.name;
	PSAppStoreReviews *storeReviews = (PSAppStoreReviews *) [appStoreApplication.reviewsByStore objectForKey:appStore.storeId];
	if (storeReviews)
	{
		cell.countView.count = storeReviews.countTotal;
		cell.ratingView.rating = storeReviews.averageRating;
	}
	else
	{
		cell.countView.count = 0;
		cell.ratingView.rating = 0.0;
	}
	
    return cell;
}

@end

