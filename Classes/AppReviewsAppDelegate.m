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

#import "AppReviewsAppDelegate.h"
#import "ARAppReviewsStore.h"
#import "ARAppStoreApplicationsViewController.h"
#import "PSLog.h"

@interface AppReviewsAppDelegate (Private)

- (NSUserDefaults *)loadUserSettings:(NSString *)aKey;

@end


@implementation AppReviewsAppDelegate

@synthesize window, exiting, settings, operationQueue;

- (id)init
{
	if (self = [super init])
	{
		self.settings = [self loadUserSettings:@"143441"];
		self.operationQueue = [[[NSOperationQueue alloc] init] autorelease];
		networkUsageCount = 0;
		self.exiting = NO;
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	PSLogDebug(@"-->");
    // Set up the window and content view
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [window setBackgroundColor:[UIColor whiteColor]];

	// Create singleton appReviewsStore.
	appReviewsStore = [ARAppReviewsStore sharedInstance];
	if (appReviewsStore)
	{
		// Create root view controller.
		ARAppStoreApplicationsViewController *appsController = [[ARAppStoreApplicationsViewController alloc] initWithStyle:UITableViewStylePlain];

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
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppReviews" message:@"" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	PSLogDebug(@"<--");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	PSLogDebug(@"");
	// Suspend all NSOperations.
	[self makeOperationQueuesPerformSelector:@selector(suspendAllOperations)];
	// Wind down background tasks while we are not active.
	self.exiting = YES;
	[appReviewsStore save];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	PSLogDebug(@"");
	// Re-enable background tasks when we become active again.
	self.exiting = NO;
	// Resume all NSOperations.
	[self makeOperationQueuesPerformSelector:@selector(resumeAllOperations)];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	PSLogDebug(@"-->");
	// Cancel all NSOperations.
	[self makeOperationQueuesPerformSelector:@selector(cancelAllOperations)];
	// Wind down background tasks while we are exiting.
	self.exiting = YES;

	// Save data.
	[appReviewsStore save];
	[appReviewsStore close];
	PSLogDebug(@"<--");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	PSLogWarning(@"");
#ifdef DEBUG
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Warning" message:@"AppReviews is running low on memory!\nRestarting your device may alleviate memory issues." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
#endif
}

- (void)dealloc
{
    [window release];
	[navigationController release];
	[settings release];
	[operationQueue release];
    [super dealloc];
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

- (void)increaseNetworkUsageCount
{
	@synchronized (self)
	{
		networkUsageCount++;

		UIApplication *app = [UIApplication sharedApplication];
		if (networkUsageCount > 0)
			app.networkActivityIndicatorVisible = YES;
		else
			app.networkActivityIndicatorVisible = NO;
	}
}

- (void)decreaseNetworkUsageCount
{
	@synchronized (self)
	{
		if (networkUsageCount > 0)
			networkUsageCount--;

		UIApplication *app = [UIApplication sharedApplication];
		if (networkUsageCount > 0)
			app.networkActivityIndicatorVisible = YES;
		else
			app.networkActivityIndicatorVisible = NO;
	}
}

- (void)makeOperationQueuesPerformSelector:(SEL)selector
{
	PSLogDebug(@"%s", sel_getName(selector));
	// First perform selector on the appDelegate's op queue.
	[self performSelector:selector];

	// Now perform selector on all applications' op queues.
	NSArray *allApps = [[ARAppReviewsStore sharedInstance] applications];
	[allApps makeObjectsPerformSelector:selector];
}

- (void)cancelAllOperations
{
	PSLogDebug(@"");
	[self.operationQueue cancelAllOperations];
}

- (void)suspendAllOperations
{
	PSLogDebug(@"");
	[self.operationQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
	PSLogDebug(@"");
	[self.operationQueue setSuspended:NO];
}

@end
