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
#import "PSAppStoreUpdateOperation.h"
#import "PSAppStoreApplicationDetailsImporter.h"
#import "PSAppStoreApplicationReviewsImporter.h"
#import "AppCriticsAppDelegate.h"
#import "PSAppStoreTableCell.h"
#import "PSImageView.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSLog.h"


@interface PSAppStoreCountriesViewController ()

@property (nonatomic, retain) NSMutableArray *enabledStores;
@property (nonatomic, retain) NSMutableArray *displayedStores;
@property (nonatomic, retain) UIBarButtonItem *updateButton;
@property (nonatomic, retain) UILabel *remainingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *remainingSpinner;
@property (nonatomic, retain) PSAppStoreReviewsViewController *appStoreReviewsViewController;
@property (retain) PSAppStoreApplicationDetailsImporter *detailsImporter;
@property (retain) PSAppStoreApplicationReviewsImporter *reviewsImporter;
@property (nonatomic, retain) NSMutableArray *storeIdsProcessed;
@property (nonatomic, retain) NSMutableArray *storeIdsRemaining;
@property (nonatomic, retain) NSMutableArray *unavailableStoreNames;
@property (nonatomic, retain) NSMutableArray *failedStoreNames;

- (void)updateDisplayedStores;

@end

@implementation PSAppStoreCountriesViewController

@synthesize appStoreApplication, enabledStores, displayedStores, updateButton, remainingLabel, remainingSpinner, appStoreReviewsViewController, detailsImporter, reviewsImporter, storeIdsProcessed, storeIdsRemaining, unavailableStoreNames, failedStoreNames;

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

		// Create a label for toolbar.
		remainingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		remainingLabel.textColor = [UIColor whiteColor];
		remainingLabel.backgroundColor = [UIColor clearColor];
		remainingLabel.text = @"NNN remaining";
		remainingLabel.textAlignment = UITextAlignmentRight;
		UIFont *labelFont = [UIFont systemFontOfSize:14.0];
		remainingLabel.font = labelFont;
		CGSize labelSize = [remainingLabel.text sizeWithFont:labelFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 16.0) lineBreakMode:UILineBreakModeTailTruncation];
		remainingLabel.frame = CGRectMake(0.0, 0.0, labelSize.width, labelSize.height);
		remainingLabel.hidden = YES;

		// Create a spinner for toolbar.
		remainingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		remainingSpinner.hidesWhenStopped = YES;

		self.storeIdsProcessed = [NSMutableArray array];
		self.storeIdsRemaining = [NSMutableArray array];
		self.unavailableStoreNames = [NSMutableArray array];
		self.failedStoreNames = [NSMutableArray array];
		self.enabledStores = [NSMutableArray array];
		self.displayedStores = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[appStoreApplication release];
	[updateButton release];
	[remainingLabel release];
	[remainingSpinner release];
	[appStoreReviewsViewController release];
	[detailsImporter release];
	[reviewsImporter release];
	[storeIdsProcessed release];
	[storeIdsRemaining release];
	[unavailableStoreNames release];
	[failedStoreNames release];
	[enabledStores release];
	[displayedStores release];
    [super dealloc];
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	// Create a "house" button for toolbar.
	UIBarButtonItem *visitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"house.png"] style:UIBarButtonItemStylePlain target:self action:@selector(visit:)];

	// Create a flexible space for toolbar.
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	// Create a label for toolbar.
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:remainingLabel];

	// Create a spinner for toolbar.
	UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:remainingSpinner];

	// Set the items for this view's toolbar.
	NSArray *items = [NSArray arrayWithObjects:visitButton, spaceItem, labelItem, spinnerItem, nil];
	[visitButton release];
	[spaceItem release];
	[labelItem release];
	[spinnerItem release];
	self.toolbarItems = items;
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	self.toolbarItems = nil;
	self.appStoreReviewsViewController = nil;
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

	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kPSAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kPSAppStoreUpdateOperationDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kPSAppStoreUpdateOperationDidFailNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPSAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPSAppStoreUpdateOperationDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPSAppStoreUpdateOperationDidFailNotification object:nil];
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

- (void)updateAllDetails:(id)sender
{
	// User tapped the Update button - queue up the download operations.

	// First cancel all current/pending operations for this app.
	[appStoreApplication cancelAllOperations];

	// Add operations to the queue for processing.
	[appStoreApplication suspendAllOperations];
	for (PSAppStore *appStore in enabledStores)
	{
		// Only add this store if it is enabled for this app.
		if (appStore.enabled)
		{
			PSAppStoreApplicationDetails *details = [[PSAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
			details.state = PSAppStoreStatePending;
			PSAppStoreUpdateOperation *op = [[PSAppStoreUpdateOperation alloc] initWithApplicationDetails:details];

			// Make sure that the "home store" for this app has a high priority in the queue.
			if ([appStore.storeIdentifier isEqualToString:appStoreApplication.defaultStoreIdentifier])
				[op setQueuePriority:NSOperationQueuePriorityHigh];
			else
				[op setQueuePriority:NSOperationQueuePriorityNormal];

			[appStoreApplication addUpdateOperation:op];
			[op release];
		}
	}

	// Refresh table.
	[self.tableView reloadData];
	// Update toolbar items.
	remainingLabel.text = [NSString stringWithFormat:@"%d remaining", appStoreApplication.updateOperationsCount];
	[remainingSpinner startAnimating];
	// Start processing.
	[appStoreApplication resumeAllOperations];
}

// Called on main thread after Start/Finish/Fail.
- (void)appStoreReviewsUpdated:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	PSAppStoreApplicationDetails *lastStoreProcessed = (PSAppStoreApplicationDetails *) [notification object];

	// Only pay attention to this notification if it is for our current application.
	if ([lastStoreProcessed.appIdentifier isEqualToString:appStoreApplication.appIdentifier])
	{
		// Update table to show any store's reviews that were just completed.
		[self updateDisplayedStores];

		// Fill in missing app details if we have them available in last processed store reviews.
		if ((appStoreApplication.name==nil || appStoreApplication.company==nil) && [[notification name] isEqualToString:kPSAppStoreUpdateOperationDidFinishNotification])
		{
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
	}
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
	// Update toolbar items.
	if (appStoreApplication.updateOperationsCount > 0)
	{
		remainingLabel.text = [NSString stringWithFormat:@"%d remaining", appStoreApplication.updateOperationsCount];
		remainingLabel.hidden = NO;
		[remainingSpinner startAnimating];
	}
	else
	{
		remainingLabel.hidden = YES;
		[remainingSpinner stopAnimating];
	}
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
	// Lazily create reviews view controller.
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
		cell.state = storeDetails.state;
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
		cell.state = PSAppStoreStateDefault;
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

