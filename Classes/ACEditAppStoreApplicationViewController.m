//
//  ACEditAppStoreApplicationViewController.m
//  AppCritics
//
//  Created by Charles Gamble on 15/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "ACEditAppStoreApplicationViewController.h"
#import "PSSelectionListViewController.h"
#import "ACAppReviewsStore.h"
#import "ACAppStoreApplication.h"
#import "ACAppStoreVerifyOperation.h"
#import "ACAppStoreApplicationDetailsImporter.h"
#import "ACAppStore.h"
#import "PSProgressHUD.h"
#import "AppCriticsAppDelegate.h"
#import "PSLog.h"


@implementation ACEditAppStoreApplicationViewController

@synthesize appId, label, defaultStoreButton, saveButton, defaultStore, app, selectionListViewController;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
        // Custom initialization
		self.selectionListViewController = nil;
		self.defaultStore = kDefaultStoreId;
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[appId release];
	[label release];
	[defaultStoreButton release];
	[defaultStore release];
	[saveButton release];
	[app release];
	[selectionListViewController release];
    [super dealloc];
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
    [super viewDidLoad];

    // Add navigation item buttons.
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																			  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveItem;
	saveButton = [saveItem retain];
    [saveItem release];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    [cancelItem release];

    // Adjust the fonts.
    appId.font = [UIFont boldSystemFontOfSize:16];
    label.font = [UIFont systemFontOfSize:14];

    // Set the view background to match the grouped tables in the other views.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	if (app)
	{
		appId.text = app.appIdentifier;
	}
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Release IBOutlets and items which can be recreated in viewDidLoad.
	self.appId = nil;
	self.label = nil;
	self.defaultStoreButton = nil;
	self.saveButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Update save button's enabled/disabled status by faking an edit.
	[self textField:appId shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
	[appId becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)setApp:(ACAppStoreApplication *)inApp
{
	[inApp retain];
	[app release];
	app = inApp;

	appId.text = app.appIdentifier;
	self.defaultStore = app.defaultStoreIdentifier;
}

- (IBAction)cancel:(id)sender
{
    // cancel edits
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	// Hide the keyboard.
	[appId resignFirstResponder];

	// Check that new appId does already exist in app list.
	ACAppStoreApplication *appForNewAppId = [[ACAppReviewsStore sharedInstance] applicationForIdentifier:appId.text];
	if (appForNewAppId && (appForNewAppId != app))
	{
		// Duplicate appId.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:@"This Application Identifier already exists in AppCritics! Please choose another Application Identifier." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		saveButton.enabled = NO;
	}
	else
	{
		// Validate appId against storeId by fetching details from store.
		ACAppStoreVerifyOperation *op = [[ACAppStoreVerifyOperation alloc] initWithAppIdentifier:appId.text storeIdentifier:self.defaultStore];
		[op setQueuePriority:NSOperationQueuePriorityVeryHigh];


		ACAppStore *store = [[ACAppReviewsStore sharedInstance] storeForIdentifier:self.defaultStore];

		PSProgressHUD *progressHUD = [[[PSProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		progressHUD.parentView = appDelegate.window;
		progressHUD.titleLabel.text = @"Verifying Application Identifier";
		progressHUD.bezelPosition = PSProgressHUDBezelPositionCenter;
		progressHUD.bezelSize = CGSizeMake(240.0, 110.0);
		op.progressHUD = progressHUD;
		// Show progress HUD.
		[progressHUD progressBeginWithMessage:store.name];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailsUpdated:) name:kACAppStoreVerifyOperationDidFinishNotification object:op];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailsUpdated:) name:kACAppStoreVerifyOperationDidFailNotification object:op];
		[appDelegate.operationQueue addOperation:op];
		[op release];
	}
}

- (void)validateApplication:(ACAppStoreApplicationDetailsImporter *)detailsImporter
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kACAppStoreVerifyOperationDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kACAppStoreVerifyOperationDidFailNotification object:nil];

	if (detailsImporter)
	{
		if (!appDelegate.exiting)
		{
			if (detailsImporter.appName && detailsImporter.appCompany)
			{
				// Name and Company were successfully retrieved.

				// Remember the previous appId, so we can tell if it has been changed.
				NSString *previousAppId = nil;
				if (app.appIdentifier)
					previousAppId = [app.appIdentifier copy];

				// Save the new details into the application.
				app.appIdentifier = detailsImporter.appIdentifier;
				app.defaultStoreIdentifier = detailsImporter.storeIdentifier;
				app.name = detailsImporter.appName;
				app.company = detailsImporter.appCompany;

				if (previousAppId)
				{
					// We are editing an existing app, so check to see if the appId has changed.
					if (![previousAppId isEqualToString:detailsImporter.appIdentifier])
					{
						// AppId has been changed to a different Id, so delete all review data for old appId.
						[[ACAppReviewsStore sharedInstance] resetDetailsForApplication:app];
					}
					[previousAppId release];
				}
				else
				{
					// We are adding a new application.

					// Add new application to list.
					[[ACAppReviewsStore sharedInstance] addApplication:app atIndex:0];
				}

				[self.navigationController popViewControllerAnimated:YES];
			}
			else
			{
				// Could not validate appId.
				saveButton.enabled = NO;

				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:@"This Application Identifier could not be found in the chosen App Store. Please check the Application Identifier and network connection before trying again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	}
}

// This is called on the main thread.
- (void)detailsUpdated:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);

	ACAppStoreVerifyOperation *op = (ACAppStoreVerifyOperation *) [notification object];
	if ([op.detailsImporter.appIdentifier isEqualToString:appId.text] && [op.detailsImporter.storeIdentifier isEqualToString:self.defaultStore])
	{
		// Hide the progress HUD.
		[op.progressHUD progressEnd];

		[self validateApplication:op.detailsImporter];
	}
}

- (IBAction)chooseDefaultStore:(id)sender
{
	// Lazily create the SelectionList view.
	if (selectionListViewController == nil)
	{
		PSSelectionListViewController *viewController = [[PSSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
		self.selectionListViewController = viewController;
		[viewController release];
	}
	self.selectionListViewController.allowMultipleSelections = NO;
	self.selectionListViewController.minimumRequiredSelections = 1;
	self.selectionListViewController.listTitle = @"Default Store";
	self.selectionListViewController.listPrompt = @"Choose a default store for this application";
	// Preselect current value.
	NSMutableArray *listLabels = [NSMutableArray array];
	NSMutableArray *listImages = [NSMutableArray array];
	NSMutableArray *listValues = [NSMutableArray array];
	NSMutableArray *listSelections = [NSMutableArray array];
	for (ACAppStore *store in [[ACAppReviewsStore sharedInstance] appStores])
	{
		[listLabels addObject:store.name];
		[listImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", store.storeIdentifier]]];
		[listValues addObject:store.storeIdentifier];
		[listSelections addObject:[NSNumber numberWithBool:NO]];
	}
	NSUInteger selIndex = [listValues indexOfObject:self.defaultStore];
	[listSelections replaceObjectAtIndex:selIndex withObject:[NSNumber numberWithBool:YES]];
	self.selectionListViewController.initialScrollPosition = [NSIndexPath indexPathForRow:selIndex inSection:0];
	// Setup and show view controller.
	self.selectionListViewController.returnTarget = self;
	self.selectionListViewController.returnSelector = @selector(updateDefaultStore:);
	[self.selectionListViewController setListLabels:listLabels images:listImages values:listValues selections:listSelections];
	[self.navigationController pushViewController:self.selectionListViewController animated:YES];
}

- (void)updateDefaultStore:(NSArray *)selectedValues
{
	// Only a single value allowed.
	if (selectedValues && [selectedValues count] == 1)
	{
		self.defaultStore = [selectedValues objectAtIndex:0];
	}
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	PSLog(@"range=[location:%d, length:%d] replacementString=\"%@\"", range.location, range.length, string);

	// Validate character is valid for appId.
	const char *newText = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (newText != NULL)
	{
		int i = 0;
		for (i = 0; i < strlen(newText); i++)
		{
			char c = newText[i];
			// Allowed characters are:
			// * numeric
			if (!isdigit(c))
			{
				// Invalid character.
				return NO;
			}
		}
	}
	else
	{
		// Could not convert string to ASCII.
		return NO;
	}

	// NOTE: If we reach this point, we know we have accepted a valid character.
	switch (theTextField.tag)
	{
		case 0:
			// Validate appId field - only enable save button if it is not empty.
			if (([theTextField.text length] - range.length + [string length]) > 0)
				saveButton.enabled = YES;
			else
				saveButton.enabled = NO;
			break;
	}

	return YES;
}

@end
