//
//  AppCriticsAppDelegate.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright Charles Gamble 2008. All rights reserved.
//

#import "AppCriticsAppDelegate.h"
#import "PSAppReviewsStore.h"
#import "PSAppStoreApplicationsViewController.h"
#import "PSLog.h"

@interface AppCriticsAppDelegate (Private)

- (NSUserDefaults *)loadUserSettings:(NSString *)aKey;

@end


@implementation AppCriticsAppDelegate

@synthesize window, exiting, settings;

- (id)init
{
	if (self = [super init])
	{
		self.settings = [self loadUserSettings:@"143441"];
		self.exiting = NO;
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Set up the window and content view
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [window setBackgroundColor:[UIColor whiteColor]];

	// Create singleton appReviewsStore.
	appReviewsStore = [PSAppReviewsStore sharedInstance];
	if (appReviewsStore)
	{
		// Create root view controller.
		PSAppStoreApplicationsViewController *appsController = [[PSAppStoreApplicationsViewController alloc] initWithStyle:UITableViewStylePlain];

		// Create a navigation controller using the new controller.
		navigationController = [[UINavigationController alloc] initWithRootViewController:appsController];
		[appsController release];

		// Add the navigation controller's view to the window.
		[window addSubview:[navigationController view]];

		[window makeKeyAndVisible];
	}
	else
	{
		// Failed to open database.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppCritics" message:@"" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	PSLogDebug(@"");
	// Wind down background tasks while we are not active.
	self.exiting = YES;
	[appReviewsStore save];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	PSLogDebug(@"");
	// Re-enable background tasks when we become active again.
	self.exiting = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	PSLogDebug(@"");
	// Wind down background tasks while we are exiting.
	self.exiting = YES;

	// Save data.
	[appReviewsStore save];
	[appReviewsStore close];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	PSLogWarning(@"");
#ifdef DEBUG
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Warning" message:@"AppCritics is running low on memory!\nRestarting your device may alleviate memory issues." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
#endif
}

- (void)dealloc
{
    [window release];
	[navigationController release];
	[settings release];
    [super dealloc];
}

/*- (void)saveData
{
	PSLogDebug(@"-->");

	// Build filename.
	NSString *documentFilename = [self.documentsPath stringByAppendingPathComponent:@"appsList.archive"];

	// Delete existing file.
	BOOL isDirectory = NO;
	if ( [[NSFileManager defaultManager] fileExistsAtPath:documentFilename isDirectory:&isDirectory] )
	{
		[[NSFileManager defaultManager] removeItemAtPath:documentFilename error:NULL];
	}

	// Write new file.
	PSLog(@"Saving apps list to: %@", documentFilename);
	if ([NSKeyedArchiver archiveRootObject:appStoreApplications toFile:documentFilename])
	{
		// Save reviews files for all appIds.
		for (PSAppStoreApplication *thisApp in appStoreApplications)
		{
			for (PSAppStoreReviews *reviews in [thisApp.reviewsByStore allValues])
			{
				[reviews saveReviews];
			}
		}
	}
	else
	{
		PSLogError(@"Could not save apps list");
	}

	PSLogDebug(@"<--");
}*/

/*- (void)loadData
{
	PSLogDebug(@"-->");
	BOOL loaded = NO;

	// Build filename.
	NSString *documentFilename = [self.documentsPath stringByAppendingPathComponent:@"appsList.archive"];

	// Does file exist?
	BOOL isDirectory = NO;
	if ( [[NSFileManager defaultManager] fileExistsAtPath:documentFilename isDirectory:&isDirectory] )
	{
		NSMutableArray *newApps;

		PSLog(@"Loading apps list from: %@", documentFilename);
		newApps = [NSKeyedUnarchiver unarchiveObjectWithFile:documentFilename];
		if (newApps)
		{
			[newApps retain];
			[appStoreApplications release];
			appStoreApplications = newApps;
			// We successfully read apps list from the file.
			loaded = YES;
#ifdef DEBUG
			// Print out apps list.
			PSLog(@"Loaded apps list:");
			for (PSAppStoreApplication *app in newApps)
			{
				PSLog(@"  %@: %@", app.appIdentifier, app.name);
			}
#endif
		}
		else
		{
			PSLogError(@"Failed to load apps list");
		}

		PSLog(@"Loaded %d apps", [appStoreApplications count]);
	}
	else
	{
		// File does not exist.
#ifdef DEBUG
		[self setupTestData];
#endif
		// Start new user off with some default applications.
		[appStoreApplications addObject:[[[PSAppStoreApplication alloc] initWithName:@"EventHorizon" appIdentifier:@"303143596"] autorelease]];
		[appStoreApplications addObject:[[[PSAppStoreApplication alloc] initWithName:@"SleepOver" appIdentifier:@"286546049"] autorelease]];
		PSLog(@"Added %d apps", [appStoreApplications count]);
	}

	PSLogDebug(@"<--");
}*/

- (NSUserDefaults *)loadUserSettings:(NSString *)aKey
{
	// Load user settings.
	NSUserDefaults *tmpSettings = [NSUserDefaults standardUserDefaults];
	if (![tmpSettings stringForKey:aKey])
	{
		// The settings haven't been initialized, so manually init them based on
		// the contents of the the settings bundle.
		NSString *bundle = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
		NSDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:bundle] objectForKey:@"PreferenceSpecifiers"];
		NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

		// Loop through the bundle settings preferences and pull out the key/default pairs.
		for (NSDictionary* setting in plist)
		{
			NSString *key = [setting objectForKey:@"Key"];
			if (key)
				[defaults setObject:[setting objectForKey:@"DefaultValue"] forKey:key];
		}

		// Persist the newly initialized default settings and reload them.
		[tmpSettings setPersistentDomain:defaults forName:[[NSBundle mainBundle] bundleIdentifier]];
		tmpSettings = [NSUserDefaults standardUserDefaults];
	}

	return tmpSettings;
}

@end
