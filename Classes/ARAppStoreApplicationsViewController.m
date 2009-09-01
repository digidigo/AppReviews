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

#import "ARAppStoreApplicationsViewController.h"
#import "ARAppStoreCountriesViewController.h"
#import "ARAppReviewsStore.h"
#import "ARAppStoreApplication.h"
#import "AREditAppStoreApplicationViewController.h"
#import "AppReviewsAppDelegate.h"
#import "PSAboutViewController.h"
#import "PSLog.h"


@interface ARAppStoreApplicationsViewController ()

@property (nonatomic, retain) NSNumber *savedEditingState;

@end


@implementation ARAppStoreApplicationsViewController

@synthesize editAppStoreApplicationViewController, appStoreCountriesViewController, savedEditingState;

- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.title = @"Applications";
    }
    return self;
}

- (void)dealloc
{
	[editAppStoreApplicationViewController release];
	[appStoreCountriesViewController release];
	[savedEditingState release];
    [super dealloc];
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	// Add the "Edit" button to the navigation bar
	UINavigationItem *navItem = self.navigationItem;
	[navItem setRightBarButtonItem:[self editButtonItem] animated:YES];
	// Set the back button title.
	navItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apps", @"Apps") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

	// Restore the editing state if it was previously saved during an unload.
	if (self.savedEditingState)
	{
		[self setEditing:[self.savedEditingState boolValue] animated:NO];
		self.savedEditingState = nil;
	}
	else
		self.editing = NO;
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Store the editing state in case we get re-created after being unloaded.
	self.savedEditingState = [NSNumber numberWithBool:self.editing];

	self.appStoreCountriesViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

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
		editAppStoreApplicationViewController = [[AREditAppStoreApplicationViewController alloc] initWithNibName:@"AREditAppStoreApplicationView" bundle:nil];
	}
	// Configure view.
	editAppStoreApplicationViewController.title = @"New Application";
	editAppStoreApplicationViewController.app = [[[ARAppStoreApplication alloc] init] autorelease];
	[[self navigationController] pushViewController:editAppStoreApplicationViewController animated:YES];
}

- (void)showAbout:(id)sender
{
	PSAboutViewController *aboutView = [[[PSAboutViewController alloc] initWithParentViewForConfirmation:self.navigationController.view] autorelease];
	[[self navigationController] pushViewController:aboutView animated:YES];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	PSLog(@"Tapped on disclosure for row %d", indexPath.row);
	ARAppStoreApplication *app = [[ARAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	// Lazily create edit view.
	if (editAppStoreApplicationViewController == nil)
	{
		editAppStoreApplicationViewController = [[AREditAppStoreApplicationViewController alloc] initWithNibName:@"AREditAppStoreApplicationView" bundle:nil];
	}
	// Configure view.
	editAppStoreApplicationViewController.title = app.name;
	//editAppStoreApplicationViewController.title = @"Edit Application";
	editAppStoreApplicationViewController.app = app;
	[[self navigationController] pushViewController:editAppStoreApplicationViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ARAppStoreApplication *app = [[ARAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	// Lazily create countries view controller.
	if (self.appStoreCountriesViewController == nil)
	{
		ARAppStoreCountriesViewController *viewController = [[ARAppStoreCountriesViewController alloc] initWithNibName:nil bundle:nil];
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
    return [[ARAppReviewsStore sharedInstance] applicationCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	ARAppStoreApplication *app = [[ARAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
	if (app.name==nil || [app.name length]==0)
		cell.textLabel.text = app.appIdentifier;
	else
		cell.textLabel.text = app.name;

	if (app.company)
		cell.detailTextLabel.text = app.company;
	else
		cell.detailTextLabel.text = @"Waiting for first update";

	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

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
		ARAppStoreApplication *app = [[ARAppReviewsStore sharedInstance] applicationAtIndex:indexPath.row];
		[[ARAppReviewsStore sharedInstance] removeApplication:app];
		[[ARAppReviewsStore sharedInstance] save];

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
		for (appIndex = 0; appIndex < [[ARAppReviewsStore sharedInstance] applicationCount]; appIndex++)
		{
			ARAppStoreApplication *anApp = [[ARAppReviewsStore sharedInstance] applicationAtIndex:appIndex];
			PSLog(@"%d: %@", appIndex, anApp.name);
		}
#endif
		// Move array elements to match moved rows.
		[[ARAppReviewsStore sharedInstance] moveApplicationAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
#ifdef DEBUG
		// Print out apps list AFTER reorder.
		PSLog(@"Apps list AFTER reorder:");
		for (appIndex = 0; appIndex < [[ARAppReviewsStore sharedInstance] applicationCount]; appIndex++)
		{
			ARAppStoreApplication *anApp = [[ARAppReviewsStore sharedInstance] applicationAtIndex:appIndex];
			PSLog(@"%d: %@", appIndex, anApp.name);
		}
#endif
		[[ARAppReviewsStore sharedInstance] save];
	}
}

@end

