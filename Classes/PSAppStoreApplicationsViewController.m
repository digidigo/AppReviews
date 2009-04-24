//
//  PSAppStoreApplicationsViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreApplicationsViewController.h"
#import "PSAppStoreCountriesViewController.h"
#import "PSAppStoreApplicationTableCell.h"
#import "PSAppReviewsStore.h"
#import "PSAppStoreApplication.h"
//#import "PSAppStoreReviews.h"
#import "PSEditAppStoreApplicationViewController.h"
#import "AppCriticsAppDelegate.h"
#import "PSAboutViewController.h"
#import "PSLog.h"


@implementation PSAppStoreApplicationsViewController

@synthesize editAppStoreApplicationViewController, appStoreCountriesViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.title = @"Applications";
		self.appStoreCountriesViewController = nil;
    }
    return self;
}

- (void)dealloc
{
	[editAppStoreApplicationViewController release];
	[appStoreCountriesViewController release];
    [super dealloc];
}

- (void)loadView
{
	[super loadView];
	
	// Add the "Edit" button to the navigation bar
	UINavigationItem *navItem = self.navigationItem;
	[navItem setRightBarButtonItem:[self editButtonItem] animated:YES];
	// Set the back button title.
	navItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apps", @"Apps") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	
	self.editing = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Deselect any selected row.
	NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
	if (selectedRow)
		[self.tableView deselectRowAtIndexPath:selectedRow animated:NO];
	
	[self.tableView reloadData];
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated 
{ 
	UINavigationItem *navItem = self.navigationItem;
	PSLogDebug(@"editing=%d, animated=%d", flag, animated);
	
	[super setEditing:flag animated:animated]; 
	if (flag == YES)
	{
		// Change view to an editable view 
		
		// Remove the "About" button from the navigation bar, replace with an Add button.
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAppStoreApplication:)];
		[navItem setLeftBarButtonItem:button animated:YES];
		[button release];
	} 
	else
	{ 
		// Save the changes if needed and change view to non-editable 
		
		// Add the "About" button to the navigation bar
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(showAbout:)];
		[navItem setLeftBarButtonItem:button animated:YES];
		[button release];
	}
} 

- (void)addAppStoreApplication:(id)sender
{
	// Lazily create edit view.
	if (editAppStoreApplicationViewController == nil)
	{
		editAppStoreApplicationViewController = [[PSEditAppStoreApplicationViewController alloc] initWithNibName:@"PSEditAppStoreApplicationView" bundle:nil];
	}
	// Configure view.
	editAppStoreApplicationViewController.title = @"New Application";
	editAppStoreApplicationViewController.app = [[[PSAppStoreApplication alloc] init] autorelease];
	[[self navigationController] pushViewController:editAppStoreApplicationViewController animated:YES];
}

- (void)showAbout:(id)sender
{
	PSAboutViewController *aboutView = [[[PSAboutViewController alloc] initWithParentViewForConfirmation:self.navigationController.view] autorelease];
	[[self navigationController] pushViewController:aboutView animated:YES];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDetailDisclosureButton;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	PSLog(@"Tapped on disclosure for row %d", indexPath.row);
	PSAppStoreApplication *app = [[PSAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	// Lazily create edit view.
	if (editAppStoreApplicationViewController == nil)
	{
		editAppStoreApplicationViewController = [[PSEditAppStoreApplicationViewController alloc] initWithNibName:@"PSEditAppStoreApplicationView" bundle:nil];
	}
	// Configure view.
	editAppStoreApplicationViewController.title = app.name;
	//editAppStoreApplicationViewController.title = @"Edit Application";
	editAppStoreApplicationViewController.app = app;
	[[self navigationController] pushViewController:editAppStoreApplicationViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSAppStoreApplication *app = [[PSAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	// Lazily create countries view controller.
	if (self.appStoreCountriesViewController == nil)
	{
		PSAppStoreCountriesViewController *viewController = [[PSAppStoreCountriesViewController alloc] initWithStyle:UITableViewStylePlain];
		self.appStoreCountriesViewController = viewController;
		[viewController release];
	}
	self.appStoreCountriesViewController.appStoreApplication = app;
	[self.navigationController pushViewController:self.appStoreCountriesViewController animated:YES];
}



#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[PSAppReviewsStore sharedInstance] applicationCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppCell";
    
    PSAppStoreApplicationTableCell *cell = (PSAppStoreApplicationTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[PSAppStoreApplicationTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	PSAppStoreApplication *app = [[PSAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	if (app.name==nil || [app.name length]==0)
		cell.nameLabel.text = app.appIdentifier;
	else
		cell.nameLabel.text = app.name;
	
	if (app.company)
		cell.companyLabel.text = app.company;
	else
		cell.companyLabel.text = @"Waiting for first update";

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		PSLog(@"Deleting row %d", indexPath.row);
		PSAppStoreApplication *app = [[PSAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
		[[PSAppReviewsStore sharedInstance] removeApplication:app];
		[[PSAppReviewsStore sharedInstance] save];
		
		// Confirm back to GUI that row has been deleted from model.
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row != toIndexPath.row)
	{
		PSLog(@"Moving row %d to %d", fromIndexPath.row, toIndexPath.row);
#ifdef DEBUG
		// Print out apps list BEFORE reorder.
		NSUInteger appIndex;
		PSLog(@"Apps list BEFORE reorder:");
		for (appIndex = 0; appIndex < [[PSAppReviewsStore sharedInstance] applicationCount]; appIndex++)
		{
			PSAppStoreApplication *anApp = [[PSAppReviewsStore sharedInstance] applicationAtIndex:appIndex];
			PSLog(@"%d: %@", appIndex, anApp.name);
		}
#endif
		// Move array elements to match moved rows.
		[[PSAppReviewsStore sharedInstance] moveApplicationAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
#ifdef DEBUG
		// Print out apps list AFTER reorder.
		PSLog(@"Apps list AFTER reorder:");
		for (appIndex = 0; appIndex < [[PSAppReviewsStore sharedInstance] applicationCount]; appIndex++)
		{
			PSAppStoreApplication *anApp = [[PSAppReviewsStore sharedInstance] applicationAtIndex:appIndex];
			PSLog(@"%d: %@", appIndex, anApp.name);
		}
#endif
		[[PSAppReviewsStore sharedInstance] save];
	}
}

@end

