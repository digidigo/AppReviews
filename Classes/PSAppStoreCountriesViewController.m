//
//  PSAppStoreCountriesViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppReviewsStore.h"
#import "PSAppStoreCountriesViewController.h"
#import "PSAppStoreReviewsViewController.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreApplicationDetailsImporter.h"
#import "PSAppStoreApplicationReviewsImporter.h"
#import "AppCriticsAppDelegate.h"
#import "PSProgressHUD.h"
#import "PSAppStoreTableCell.h"
#import "PSImageView.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSLog.h"


@interface PSAppStoreCountriesViewController ()

@property (nonatomic, retain) NSMutableArray *enabledStores;
@property (nonatomic, retain) NSMutableArray *displayedStores;
@property (nonatomic, retain) UIBarButtonItem *updateButton;
@property (nonatomic, retain) PSAppStoreReviewsViewController *appStoreReviewsViewController;
@property (retain) PSAppStoreApplicationDetailsImporter *detailsImporter;
@property (retain) PSAppStoreApplicationReviewsImporter *reviewsImporter;
@property (retain) PSProgressHUD *progressHUD;
@property (nonatomic, retain) NSMutableArray *storeIdsProcessed;
@property (nonatomic, retain) NSMutableArray *storeIdsRemaining;
@property (nonatomic, retain) NSMutableArray *unavailableStoreNames;
@property (nonatomic, retain) NSMutableArray *failedStoreNames;

- (void)updateDisplayedStores;
- (void)updateDetails:(PSProgressHUD *)inProgressBarSheet;

@end

@implementation PSAppStoreCountriesViewController

@synthesize appStoreApplication, enabledStores, displayedStores, updateButton, appStoreReviewsViewController, detailsImporter, reviewsImporter, progressHUD, storeIdsProcessed, storeIdsRemaining, unavailableStoreNames, failedStoreNames;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		self.title = @"Countries";
		self.appStoreReviewsViewController = nil;
		self.detailsImporter = nil;
		self.reviewsImporter = nil;

		// Add the Update button.
		self.updateButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateAllDetails:)] autorelease];
		self.navigationItem.rightBarButtonItem = self.updateButton;

		// Set the back button title.
		self.navigationItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Countries", @"Countries") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

		AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		self.progressHUD = [[[PSProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		self.progressHUD.parentView = appDelegate.window;
		self.progressHUD.titleLabel.text = @"Processing App Reviews";
		self.progressHUD.bezelPosition = PSProgressHUDBezelPositionCenter;
		self.progressHUD.bezelSize = CGSizeMake(240.0, 110.0);

		self.storeIdsProcessed = [NSMutableArray array];
		self.storeIdsRemaining = [NSMutableArray array];
		self.unavailableStoreNames = [NSMutableArray array];
		self.failedStoreNames = [NSMutableArray array];
		self.enabledStores = [NSMutableArray array];
		self.displayedStores = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	// Set the items for this view's toolbar.
	UIBarButtonItem *visitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"house.png"] style:UIBarButtonItemStylePlain target:self action:@selector(visit:)];
	NSArray *items = [NSArray arrayWithObject:visitButton];
	[visitButton release];
	self.toolbarItems = items;
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	self.toolbarItems = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Build up a list of enabled stores.
	[enabledStores removeAllObjects];
	for (PSAppStore *store in [[PSAppReviewsStore sharedInstance] appStores])
	{
		if (store.enabled)
		{
			[enabledStores addObject:store];
		}
	}

	[self updateDisplayedStores];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[appStoreApplication release];
	[updateButton release];
	[appStoreReviewsViewController release];
	[detailsImporter release];
	[reviewsImporter release];
	[progressHUD release];
	[storeIdsProcessed release];
	[storeIdsRemaining release];
	[unavailableStoreNames release];
	[failedStoreNames release];
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
		self.title = appStoreApplication.appIdentifier;
}

- (void)updateDisplayedStores
{
	// Updates the tableview and takes account of the hideEmptyCountries setting.
	[displayedStores removeAllObjects];
	for (PSAppStore *appStore in enabledStores)
	{
		PSAppStoreApplicationDetails *details = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
		// Only add store if it has any ratings/reviews OR we are not hiding empty stores.
		if ((details && (details.reviewCountAll + details.reviewCountCurrent + details.ratingCountAll + details.ratingCountCurrent) > 0) ||
			([[NSUserDefaults standardUserDefaults] boolForKey:@"hideEmptyCountries"] == NO))
		{
			[displayedStores addObject:appStore];
		}
	}

	// Refresh table.
	[self.tableView reloadData];
}

- (void)updateAllDetails:(id)sender
{
	// Build array of all storeIds for processing.
	[storeIdsProcessed removeAllObjects];
	[storeIdsRemaining removeAllObjects];
	[unavailableStoreNames removeAllObjects];
	[failedStoreNames removeAllObjects];
	for (PSAppStore *appStore in enabledStores)
	{
		// Only add this store if it is enabled for this app.
		if (appStore.enabled)
		{
			// Make sure that the "home store" for this is first in the list.
			if ([appStore.storeIdentifier isEqualToString:appStoreApplication.defaultStoreIdentifier])
				[storeIdsRemaining insertObject:appStore.storeIdentifier atIndex:0];
			else
				[storeIdsRemaining addObject:appStore.storeIdentifier];
		}
	}

	// Show progress view.
	[progressHUD progressBeginWithMessage:@"Connecting"];

	// Start processing first entry in storeIds array.
	[self updateDetails:progressHUD];
}

// Always call on main thread.
// Called when a store download/parse has completed, or been cancelled, or failed.
- (void)updateDetails:(PSProgressHUD *)inProgressBarSheet
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	if (appDelegate.exiting)
	{
		// Remove modal progress view because we are exiting.
		[progressHUD progressUpdate:[NSNumber numberWithFloat:1.0f]];
		[progressHUD progressEnd];
	}
	else
	{
		// Update table to show any store's reviews that were just completed.
		[self updateDisplayedStores];

		// Fill in missing app details if we have them available in last processed store reviews.
		if ((appStoreApplication.name==nil || appStoreApplication.company==nil) && [storeIdsProcessed count] > 0)
		{
			NSString *lastStoreIdProcessed = [storeIdsProcessed lastObject];
			PSAppStore *lastStore = [[PSAppReviewsStore sharedInstance] storeForIdentifier:lastStoreIdProcessed];
			PSAppStoreApplicationDetails *lastStoreProcessed = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:lastStore];
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

		// See if the last store failed.
		if ([storeIdsProcessed count] > 0)
		{
			if (detailsImporter.importState == DetailsImportStateUnavailable)
			{
				// App is not available in this store.
				PSAppStore *failedStore = [[PSAppReviewsStore sharedInstance] storeForIdentifier:detailsImporter.storeIdentifier];
				[unavailableStoreNames addObject:failedStore.name];
			}
			else if (!((detailsImporter.importState == DetailsImportStateComplete) && (reviewsImporter.importState == ReviewsImportStateComplete)))
			{
				// This store failed to download/parse.
				PSAppStore *failedStore = [[PSAppReviewsStore sharedInstance] storeForIdentifier:detailsImporter.storeIdentifier];
				[failedStoreNames addObject:failedStore.name];
			}
		}

		// See if we still have stores to process.
		if ([storeIdsRemaining count] > 0)
		{
			// We still have stores to process.
			NSString *thisStoreId = [storeIdsRemaining objectAtIndex:0];
			PSAppStore *thisStore = [[PSAppReviewsStore sharedInstance] storeForIdentifier:thisStoreId];
			PSAppStoreApplicationDetails *appStoreDetails = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:thisStore];
			float progress = ((float)([enabledStores count]-[storeIdsRemaining count])/(float)[enabledStores count]);
			[progressHUD progressUpdateMessage:[[[PSAppReviewsStore sharedInstance] storeForIdentifier:appStoreDetails.storeIdentifier] name]];
			[progressHUD progressUpdate:[NSNumber numberWithFloat:progress]];

			self.detailsImporter = [[[PSAppStoreApplicationDetailsImporter alloc] initWithAppIdentifier:appStoreApplication.appIdentifier storeIdentifier:thisStore.storeIdentifier] autorelease];
			[detailsImporter fetchDetails:progressHUD];

			[storeIdsProcessed addObject:thisStoreId];
			[storeIdsRemaining removeObjectAtIndex:0];
		}
		else
		{
			// No more stores to process.
			[progressHUD progressUpdate:[NSNumber numberWithFloat:1.0f]];
			[progressHUD progressEnd];

			// Check to see if there were errors downloading.
			if ([storeIdsProcessed count] > 0)
			{
				if (([unavailableStoreNames count] + [failedStoreNames count]) > 0)
				{
					// We have some unavailable/failed stores.
					NSString *msg = @"An error occurred whilst downloading reviews from some contries.";
					NSString *thisAppName = @"This application";

					if (appStoreApplication.name)
						thisAppName = appStoreApplication.name;

					if ([unavailableStoreNames count] == [enabledStores count])
						msg = [NSString stringWithFormat:@"%@ is not available in any App Stores.", thisAppName];
					else if ([failedStoreNames count] == [enabledStores count])
						msg = @"AppCritics could not fetch reviews from any App Stores. Please check network connection before trying again.";
					else
					{
						msg = @"";
						if ([failedStoreNames count] > 0)
							msg = [NSString stringWithFormat:@"AppCritics could not fetch reviews from the following stores:\n%@\nPlease check network connection before trying again.", [failedStoreNames componentsJoinedByString:@"\n"]];

						if ([unavailableStoreNames count] > 0)
							msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%@%@ is not available in the following stores:\n%@", ([msg length]>0 ? @"\n\n" : @""), thisAppName, [unavailableStoreNames componentsJoinedByString:@"\n"]]];
					}

					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
					[alert show];
					[alert release];
				}
			}
		}
	}
}

// Called on same thread that sent notification.
- (void)appStoreDetailsUpdated:(NSNotification *)notification
{
	PSLogDebug(@"-->");
	if (detailsImporter.importState == DetailsImportStateComplete)
	{
		// Imported details OK, now start importing reviews for this app/store.
		[self performSelectorOnMainThread:@selector(updateReviews) withObject:nil waitUntilDone:NO];
	}
	else
	{
		// Something went wrong, move on to next store.
		[self performSelectorOnMainThread:@selector(updateDetails:) withObject:progressHUD waitUntilDone:NO];
	}
	PSLogDebug(@"<--");
}

// Called on main thread
- (void)updateReviews
{
	PSLogDebug(@"-->");
	// Imported details OK, now start importing reviews for this app/store.
	self.reviewsImporter = [[[PSAppStoreApplicationReviewsImporter alloc] initWithAppIdentifier:appStoreApplication.appIdentifier storeIdentifier:detailsImporter.storeIdentifier] autorelease];
	[self.reviewsImporter fetchReviews];
	PSLogDebug(@"<--");
}

// Called on same thread that sent notification.
- (void)appStoreReviewsUpdated:(NSNotification *)notification
{
	PSLogDebug(@"-->");
	if (reviewsImporter.importState == ReviewsImportStateComplete)
	{
		PSAppStore *store = [[PSAppReviewsStore sharedInstance] storeForIdentifier:detailsImporter.storeIdentifier];
		PSAppStoreApplicationDetails *storeDetails = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:store];
		if (storeDetails)
		{
			// Save details info for this app/store.
			NSUInteger oldRatingsCount = storeDetails.ratingCountAll;
			NSUInteger oldReviewsCount = storeDetails.reviewCountAll;
			[detailsImporter copyDetailsTo:storeDetails];
			NSUInteger newRatingsCount = storeDetails.ratingCountAll;
			NSUInteger newReviewsCount = storeDetails.reviewCountAll;
			if (newRatingsCount != oldRatingsCount)
				storeDetails.hasNewRatings = YES;
			if (newReviewsCount != oldReviewsCount)
				storeDetails.hasNewReviews = YES;
			[storeDetails save];

			// Save reviews for this app/store.
			NSArray *reviews = [reviewsImporter reviews];
			[[PSAppReviewsStore sharedInstance] setReviews:reviews forApplication:appStoreApplication inStore:store];
		}
	}
	[self performSelectorOnMainThread:@selector(updateDetails:) withObject:progressHUD waitUntilDone:YES];
	PSLogDebug(@"<--");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.navigationController setToolbarHidden:NO animated:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreDetailsUpdated:) name:kPSAppStoreApplicationDetailsUpdatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kPSAppStoreApplicationReviewsUpdatedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)visit:(id)sender
{
	NSUInteger cancelButtonIndex = 1;
	NSString *sheetTitle = (appStoreApplication.name ? appStoreApplication.name : appStoreApplication.appIdentifier);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Visit App Store", nil];

	[appStoreApplication hydrate];
	NSString *defaultStoreIdentifier = appStoreApplication.defaultStoreIdentifier;
	if (defaultStoreIdentifier && [defaultStoreIdentifier length] > 0)
	{
		PSAppStore *store = [[PSAppReviewsStore sharedInstance] storeForIdentifier:defaultStoreIdentifier];
		if (store)
		{
			PSAppStoreApplicationDetails *details = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:store];
			if (details)
			{
				[details hydrate];
				if (details.companyURL && [details.companyURL length] > 0)
				{
					[sheet addButtonWithTitle:@"Visit Company URL"];
					cancelButtonIndex++;
				}

				if (details.supportURL && [details.supportURL length] > 0)
				{
					[sheet addButtonWithTitle:@"Visit Support URL"];
					cancelButtonIndex++;
				}
			}
		}
	}

	[sheet addButtonWithTitle:@"Cancel"];
	sheet.cancelButtonIndex = cancelButtonIndex;
	[sheet showFromToolbar:[self.navigationController toolbar]];
	[sheet release];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Display reviews for store.
	PSAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	PSAppStoreApplicationDetails *appStoreDetails = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
	// Lazily create countries view controller.
	if (self.appStoreReviewsViewController == nil)
	{
		PSAppStoreReviewsViewController *viewController = [[PSAppStoreReviewsViewController alloc] initWithStyle:UITableViewStylePlain];
		self.appStoreReviewsViewController = viewController;
		[viewController release];
	}
	[appStoreDetails hydrate];
	self.appStoreReviewsViewController.appStoreDetails = appStoreDetails;
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

    PSAppStoreTableCell *cell = (PSAppStoreTableCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[PSAppStoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	PSAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	cell.nameLabel.text = appStore.name;
	cell.flagView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", appStore.storeIdentifier]];
	PSAppStoreApplicationDetails *storeDetails = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
	if (storeDetails)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.countView.count = storeDetails.reviewCountAll;
		cell.ratingView.rating = storeDetails.ratingAll;
		if (storeDetails.ratingCountAll > 0)
			cell.ratingCountLabel.text = [NSString stringWithFormat:@"in %d rating%@", storeDetails.ratingCountAll, (storeDetails.ratingCountAll==1?@"":@"s")];
		else
			cell.ratingCountLabel.text = nil;

		if (storeDetails.hasNewRatings)
		{
			[cell.ratingCountLabel setTextColor:[UIColor colorWithRed:142.0/255.0 green:217.0/255.0 blue:255.0/255.0 alpha:1.0]];
		}
		else
		{
			[cell.ratingCountLabel setTextColor:[UIColor colorWithRed:0.55 green:0.6 blue:0.7 alpha:1.0]];
		}

		if (storeDetails.hasNewReviews)
		{
			[cell.countView setLozengeColor:[UIColor colorWithRed:142.0/255.0 green:217.0/255.0 blue:255.0/255.0 alpha:1.0]];
		}
		else
		{
			[cell.countView setLozengeColor:nil];
		}
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.countView.count = 0;
		cell.ratingView.rating = 0.0;
		[cell.countView setLozengeColor:nil];
	}

    return cell;
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// Deselect table row.
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"Clicked on button %d: %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);

	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		NSURL *targetURL = nil;
		[appStoreApplication hydrate];

		if (buttonIndex == 0)
		{
			// Build URL to app store.
			targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", appStoreApplication.appIdentifier]];
		}
		else
		{
			// Build URL to company/support site.
			NSString *defaultStoreIdentifier = appStoreApplication.defaultStoreIdentifier;
			if (defaultStoreIdentifier && [defaultStoreIdentifier length] > 0)
			{
				PSAppStore *store = [[PSAppReviewsStore sharedInstance] storeForIdentifier:defaultStoreIdentifier];
				if (store)
				{
					PSAppStoreApplicationDetails *details = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:store];
					if (details)
					{
						NSMutableArray *URLs = [NSMutableArray array];
						[details hydrate];
						if (details.companyURL && [details.companyURL length] > 0)
							[URLs addObject:details.companyURL];

						if (details.supportURL && [details.supportURL length] > 0)
							[URLs addObject:details.supportURL];

						NSInteger urlIndex = buttonIndex - 1;
						if ((urlIndex >= 0) && (urlIndex < [URLs count]))
						{
							targetURL = [NSURL URLWithString:[URLs objectAtIndex:urlIndex]];
						}
					}
				}
			}
		}

		if (targetURL)
			[[UIApplication sharedApplication] openURL:targetURL];
	}
}

@end

