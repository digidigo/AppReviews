//
//  AppCriticsAppDelegate.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright Charles Gamble 2008. All rights reserved.
//

#import "AppCriticsAppDelegate.h"
#import "PSAppStore.h"
#import "PSAppStoreReviews.h"
#import "PSAppStoreApplication.h"
#import "PSAppStoreApplicationsViewController.h"
#import "NSString+PSPathAdditions.h"
#import "PSLog.h"

@interface AppCriticsAppDelegate (Private)

- (NSUserDefaults *)loadUserSettings:(NSString *)aKey;
- (void)setupAppStores;
- (void)loadData;

#ifdef DEBUG
- (void)setupTestData;
#endif

@end


@implementation AppCriticsAppDelegate

@synthesize window, exiting, settings, documentsPath, appStores, appStoreApplications;

- (id)init
{
	if (self = [super init])
	{
		self.settings = [self loadUserSettings:@"143441"];
		self.exiting = NO;
		// Find our Documents path.
		self.documentsPath = [NSString documentsPath];

		self.appStores = [NSArray array];
		self.appStoreApplications = [NSMutableArray array];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Set up the window and content view
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [window setBackgroundColor:[UIColor whiteColor]];

	[self setupAppStores];
	[self loadData];
	
	// Create root view controller.
	PSAppStoreApplicationsViewController *appsController = [[PSAppStoreApplicationsViewController alloc] initWithStyle:UITableViewStylePlain];
	
	// Create a navigation controller using the new controller.
	navigationController = [[UINavigationController alloc] initWithRootViewController:appsController];
	[appsController release];
	
	// Add the navigation controller's view to the window.
	[window addSubview:[navigationController view]];

    [window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	PSLogDebug(@"");
	// Wind down background tasks while we are not active.
	self.exiting = YES;
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
	[self saveData];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	PSLogWarning(@"");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Warning" message:@"AppCritics is running low on memory!\nRestarting your device may alleviate memory issues." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)dealloc
{
    [window release];
	[navigationController release];
	[appStores release];
	[appStoreApplications release];
	[documentsPath release];
	[settings release];
    [super dealloc];
}

- (PSAppStore *)storeForId:(NSString *)storeId
{
	for (PSAppStore *store in appStores)
	{
		if ([store.storeId isEqualToString:storeId])
			return store;
	}
	return nil;
}

- (PSAppStoreApplication *)applicationForId:(NSString *)appId
{
	for (PSAppStoreApplication *app in appStoreApplications)
	{
		if ([app.appId isEqualToString:appId])
			return app;
	}
	return nil;
}

- (void)saveData
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
}

- (void)loadData
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
				PSLog(@"  %@: %@", app.appId, app.name);
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
		[appStoreApplications addObject:[[[PSAppStoreApplication alloc] initWithName:@"EventHorizon" appId:@"303143596"] autorelease]];	
		[appStoreApplications addObject:[[[PSAppStoreApplication alloc] initWithName:@"SleepOver" appId:@"286546049"] autorelease]];	
		PSLog(@"Added %d apps", [appStoreApplications count]);
	}
	
	PSLogDebug(@"<--");
}

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
		NSMutableDictionary *defaults = [NSMutableDictionary new];
		
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

- (void)setupAppStores
{
	// Create array of App Stores.
	NSMutableArray *tmpArray = [NSMutableArray array];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"United States" storeId:@"143441"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"United Kingdom" storeId:@"143444"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Argentina" storeId:@"143505"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Australia" storeId:@"143460"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Belgium" storeId:@"143446"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Brazil" storeId:@"143503"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Canada" storeId:@"143455"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Chile" storeId:@"143483"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"China" storeId:@"143465"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Colombia" storeId:@"143501"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Costa Rica" storeId:@"143495"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Croatia" storeId:@"143494"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Czech Republic" storeId:@"143489"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Denmark" storeId:@"143458"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Deutschland" storeId:@"143443"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"El Salvador" storeId:@"143506"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Espana" storeId:@"143454"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Finland" storeId:@"143447"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"France" storeId:@"143442"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Greece" storeId:@"143448"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Guatemala" storeId:@"143504"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Hong Kong" storeId:@"143463"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Hungary" storeId:@"143482"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"India" storeId:@"143467"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Indonesia" storeId:@"143476"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Ireland" storeId:@"143449"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Israel" storeId:@"143491"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Italia" storeId:@"143450"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Japan" storeId:@"143462"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Korea" storeId:@"143466"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Kuwait" storeId:@"143493"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Lebanon" storeId:@"143497"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Luxembourg" storeId:@"143451"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Malaysia" storeId:@"143473"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Mexico" storeId:@"143468"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Nederland" storeId:@"143452"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"New Zealand" storeId:@"143461"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Norway" storeId:@"143457"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Osterreich" storeId:@"143445"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Pakistan" storeId:@"143477"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Panama" storeId:@"143485"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Peru" storeId:@"143507"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Phillipines" storeId:@"143474"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Poland" storeId:@"143478"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Portugal" storeId:@"143453"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Qatar" storeId:@"143498"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Romania" storeId:@"143487"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Russia" storeId:@"143469"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Saudi Arabia" storeId:@"143479"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Schweitz/Suisse" storeId:@"143459"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Singapore" storeId:@"143464"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Slovakia" storeId:@"143496"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Slovenia" storeId:@"143499"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"South Africa" storeId:@"143472"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Sri Lanka" storeId:@"143486"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Sweden" storeId:@"143456"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Taiwan" storeId:@"143470"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Thailand" storeId:@"143475"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Turkey" storeId:@"143480"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"United Arab Emirates" storeId:@"143481"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Venezuela" storeId:@"143502"] autorelease]];
	[tmpArray addObject:[[[PSAppStore alloc] initWithName:@"Vietnam" storeId:@"143471"] autorelease]];
	self.appStores = [tmpArray sortedArrayUsingSelector:@selector(compare:)];
}


#pragma mark -
#pragma mark DEBUG methods

#ifdef DEBUG

- (void)setupTestData
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	[tmpArray addObject:[[[PSAppStoreApplication alloc] initWithName:@"vConqr" appId:@"290649401"] autorelease]];
	[tmpArray addObject:[[[PSAppStoreApplication alloc] initWithName:@"Lux Touch" appId:@"292538570"] autorelease]];
	[tmpArray addObject:[[[PSAppStoreApplication alloc] initWithName:@"Remote" appId:@"284417350"] autorelease]];	
	[tmpArray addObject:[[[PSAppStoreApplication alloc] initWithName:@"Texas Hold'em" appId:@"284602850"] autorelease]];	
	self.appStoreApplications = tmpArray;
}

#endif

@end
