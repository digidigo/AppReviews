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

#import "ARAppReviewsStore.h"
#import "PSSynthesizeSingleton.h"
#import "ARAppStore.h"
#import "ARAppStoreApplication.h"
#import "ARAppStoreApplicationDetails.h"
#import "ARAppStoreApplicationReview.h"
#import "NSString+PSPathAdditions.h"
#import "FMDatabase.h"
#import "PSLog.h"


static NSString *kARAppReviewsDatabaseFile = @"AppReviews.db";


@interface ARAppReviewsStore ()

@property (nonatomic, retain) FMDatabase *database;

- (BOOL)open;
- (void)setupAppStores;
- (void)updatePositions;
- (void)removeDetailsForApplication:(ARAppStoreApplication *)app;
- (void)removeReviewsForApplication:(ARAppStoreApplication *)app;
- (void)removeReviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store;
- (void)loadApplications;
- (void)loadDetailsForApplication:(ARAppStoreApplication *)app;
- (void)loadReviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store;

#ifdef DEBUG
- (void)setupTestData;
#endif

@end


@implementation ARAppReviewsStore

@synthesize database, appStores;

SYNTHESIZE_SINGLETON_FOR_CLASS(ARAppReviewsStore);

+ (void)initialize
{
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users,
    // so we need to create a copy of it in the application's Documents directory.

    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *writableDBPath = [[NSString documentsPath] stringByAppendingPathComponent:kARAppReviewsDatabaseFile];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
	{
		PSLogDebug(@"Writable database file %@ found", kARAppReviewsDatabaseFile);
		return;
	}
    // The writable database does not exist, so copy the default to the appropriate location.
	PSLogDebug(@"No writable database file found");
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kARAppReviewsDatabaseFile];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success)
	{
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (ARAppReviewsStore *)init
{
	if (self = [super init])
	{
		if ([self open])
		{
			[self setupAppStores];

			applications = [[NSMutableArray array] retain];
			appDetails = [[NSMutableDictionary dictionary] retain];
			appReviews = [[NSMutableDictionary dictionary] retain];
			// We always load and hydrate the applications list.
			[self loadApplications];
		}
		else
		{
			PSLogError(@"Failed to open database");
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[database release];
	[appStores release];
	[applications release];
	[appDetails release];
	[appReviews release];
	[super dealloc];
}

- (BOOL)open
{
	BOOL result;
	// Open the database.
	NSString *path = [[NSString documentsPath] stringByAppendingPathComponent:kARAppReviewsDatabaseFile];
	self.database = [FMDatabase databaseWithPath:path];
	PSLogDebug(@"Using SQLite version %@", [FMDatabase sqliteLibVersion]);
	result = [database open];
	if (result)
		PSLogDebug(@"Opened database %@ successfully", kARAppReviewsDatabaseFile);
	else
		PSLogError(@"Failed to open database %@", kARAppReviewsDatabaseFile);
	return result;
}

- (BOOL)save
{
	// Save applications.
	[applications makeObjectsPerformSelector:@selector(save)];
	// Save details for each app, for each country.
	for (NSMutableDictionary *storeDetailsDictionary in [appDetails allValues])
	{
		NSArray *allDetailsForApp = [storeDetailsDictionary allValues];
		[allDetailsForApp makeObjectsPerformSelector:@selector(save)];
	}
	// Save all reviews for each app, for each country.
	for (NSMutableDictionary *storeReviewsDictionary in [appReviews allValues])
	{
		// storeReviewsDictionary is a dict(storeId => array(review))
		for (NSMutableArray *reviewsArray in [storeReviewsDictionary allValues])
		{
			// reviewsArray is array(review).
			[reviewsArray makeObjectsPerformSelector:@selector(save)];
		}
	}
	return YES;
}

- (void)close
{
	[database close];
	self.database = nil;
	PSLogDebug(@"Closed database %@", kARAppReviewsDatabaseFile);
}

- (ARAppStore *)storeForIdentifier:(NSString *)storeIdentifier
{
	for (ARAppStore *store in appStores)
	{
		if ([store.storeIdentifier isEqualToString:storeIdentifier])
			return store;
	}
	return nil;
}

- (NSArray *)applications
{
	return [NSArray arrayWithArray:applications];
}

- (ARAppStoreApplication *)applicationForIdentifier:(NSString *)appIdentifier
{
	for (ARAppStoreApplication *app in applications)
	{
		if ([app.appIdentifier isEqualToString:appIdentifier])
			return app;
	}
	return nil;
}

- (ARAppStoreApplication *)applicationAtIndex:(NSUInteger)index
{
	ARAppStoreApplication *result = nil;
	if (index < [applications count])
		result = [applications objectAtIndex:index];
	return result;
}

- (NSUInteger)applicationCount
{
	return [applications count];
}

- (void)addApplication:(ARAppStoreApplication *)app
{
	// Add application to database.
	[app insertIntoDatabase:database];
	[self resetDetailsForApplication:app];
	// Add application to array.
	[applications addObject:app];
	[self updatePositions];
}

- (void)addApplication:(ARAppStoreApplication *)app atIndex:(NSUInteger)index
{
	// Add application to database.
	[app insertIntoDatabase:database];
	[self resetDetailsForApplication:app];
	// Add application to array.
	[applications insertObject:app atIndex:index];
	[self updatePositions];
}

- (void)moveApplicationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	ARAppStoreApplication *app = [[applications objectAtIndex:fromIndex] retain];
	[applications removeObjectAtIndex:fromIndex];
	[applications insertObject:app atIndex:toIndex];
	[app release];
	[self updatePositions];
}

- (void)removeApplication:(ARAppStoreApplication *)app
{
	// Cancel all NSOperations for this app.
	[app suspendAllOperations];
	[app cancelAllOperations];

	// Delete actual reviews for this app.
	[self removeReviewsForApplication:app];

	// Remove any existing ARAppStoreApplicationDetails for this app.
	[self removeDetailsForApplication:app];

	// Remove app from database.
	[app deleteFromDatabase];
	// Remove app from apps array.
	[applications removeObject:app];
	[self updatePositions];
}

- (void)resetDetailsForApplication:(ARAppStoreApplication *)app
{
	// STEP 1: Delete actual reviews for this app.
	[self removeReviewsForApplication:app];

	// STEP 2: Remove any existing ARAppStoreApplicationDetails for this app.
	[self removeDetailsForApplication:app];

	// STEP 3: Create a new ARAppStoreApplicationDetails instance for this app, one for each store.
	NSMutableDictionary *storeDetailsDictionary = [NSMutableDictionary dictionary];
	for (ARAppStore *appStore in appStores)
	{
		ARAppStoreApplicationDetails *appStoreDetails = [[ARAppStoreApplicationDetails alloc] initWithAppIdentifier:app.appIdentifier storeIdentifier:appStore.storeIdentifier];
		[appStoreDetails insertIntoDatabase:database];
		[storeDetailsDictionary setObject:appStoreDetails forKey:appStore.storeIdentifier];
		[appStoreDetails release];
	}
	[appDetails setObject:storeDetailsDictionary forKey:app.appIdentifier];
}

- (ARAppStoreApplicationDetails *)detailsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store
{
	NSMutableDictionary *storeDetailsDictionary = [appDetails objectForKey:app.appIdentifier];
	if (storeDetailsDictionary == nil)
	{
		// Details for this app are not loaded yet, load now and try again.
		[self loadDetailsForApplication:app];
		storeDetailsDictionary = [appDetails objectForKey:app.appIdentifier];
	}

	if (storeDetailsDictionary)
		return [storeDetailsDictionary objectForKey:store.storeIdentifier];

	return nil;
}

- (void)removeDetailsForApplication:(ARAppStoreApplication *)app
{
	// Remove any existing ARAppStoreApplicationDetails for this app.
	NSMutableDictionary *storeDetailsDictionary = [appDetails objectForKey:app.appIdentifier];
	if (storeDetailsDictionary)
	{
		// We have found an existing dictionary of Details for this app.
		// Delete all ARAppStoreApplicationDetails objects.
		[[storeDetailsDictionary allValues] makeObjectsPerformSelector:@selector(deleteFromDatabase)];
		// Finally, delete the existing details dictionary for this app.
		[appDetails removeObjectForKey:app.appIdentifier];
	}
}

- (void)removeReviewsForApplication:(ARAppStoreApplication *)app
{
	NSMutableDictionary *storeReviewsDictionary = [appReviews objectForKey:app.appIdentifier];
	if (storeReviewsDictionary)
	{
		// Iterate through all storeIds, removing reviews as we go.
		for (NSString *storeId in [storeReviewsDictionary allKeys])
		{
			ARAppStore *store = [self storeForIdentifier:storeId];
			if (store)
			{
				[self removeReviewsForApplication:app inStore:store];
			}
		}
	}
}

- (void)removeReviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store
{
	NSArray *reviews = [self reviewsForApplication:app inStore:store];
	if (reviews)
	{
		// Delete review instances from database.
		[reviews makeObjectsPerformSelector:@selector(deleteFromDatabase)];
		// Finally, remove this store's entry from the app's dictionary.
		NSMutableDictionary *storeReviewsDictionary = [appReviews objectForKey:app.appIdentifier];
		if (storeReviewsDictionary)
		{
			[storeReviewsDictionary removeObjectForKey:store.storeIdentifier];
		}
	}
}

- (void)setReviews:(NSArray *)reviews forApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store
{
	// Delete existing reviews for this app/store.
	[self removeReviewsForApplication:app inStore:store];
	// Insert all new reviews into db.
	[reviews makeObjectsPerformSelector:@selector(insertIntoDatabase:) withObject:database];
	// Load saved reviews into dictionaries.
	[self loadReviewsForApplication:app inStore:store];
}

- (NSArray *)reviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store
{
	// Return actual reviews for this app/store.
	NSMutableArray *reviewsForAppStore = nil;
	NSMutableDictionary *storeReviewsDictionary = [appReviews objectForKey:app.appIdentifier];
	if (storeReviewsDictionary)
		reviewsForAppStore = [storeReviewsDictionary objectForKey:store.storeIdentifier];

	if (reviewsForAppStore == nil)
	{
		// Reviews for this app/store are not loaded yet, load now and try again.
		[self loadReviewsForApplication:app inStore:store];

		storeReviewsDictionary = [appReviews objectForKey:app.appIdentifier];
		if (storeReviewsDictionary)
			reviewsForAppStore = [storeReviewsDictionary objectForKey:store.storeIdentifier];
	}

	if (reviewsForAppStore)
		return [NSArray arrayWithArray:reviewsForAppStore];

	return nil;
}

- (void)setupAppStores
{
	// Create array of App Stores.
	NSMutableArray *tmpArray = [NSMutableArray array];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"United States" storeIdentifier:@"143441"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"United Kingdom" storeIdentifier:@"143444"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Argentina" storeIdentifier:@"143505"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Australia" storeIdentifier:@"143460"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Belgium" storeIdentifier:@"143446"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Brazil" storeIdentifier:@"143503"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Canada" storeIdentifier:@"143455"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Chile" storeIdentifier:@"143483"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"China" storeIdentifier:@"143465"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Colombia" storeIdentifier:@"143501"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Costa Rica" storeIdentifier:@"143495"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Croatia" storeIdentifier:@"143494"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Czech Republic" storeIdentifier:@"143489"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Denmark" storeIdentifier:@"143458"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Deutschland" storeIdentifier:@"143443"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"El Salvador" storeIdentifier:@"143506"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Espana" storeIdentifier:@"143454"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Finland" storeIdentifier:@"143447"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"France" storeIdentifier:@"143442"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Greece" storeIdentifier:@"143448"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Guatemala" storeIdentifier:@"143504"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Hong Kong" storeIdentifier:@"143463"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Hungary" storeIdentifier:@"143482"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"India" storeIdentifier:@"143467"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Indonesia" storeIdentifier:@"143476"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Ireland" storeIdentifier:@"143449"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Israel" storeIdentifier:@"143491"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Italia" storeIdentifier:@"143450"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Japan" storeIdentifier:@"143462"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Korea" storeIdentifier:@"143466"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Kuwait" storeIdentifier:@"143493"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Lebanon" storeIdentifier:@"143497"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Luxembourg" storeIdentifier:@"143451"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Malaysia" storeIdentifier:@"143473"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Mexico" storeIdentifier:@"143468"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Nederland" storeIdentifier:@"143452"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"New Zealand" storeIdentifier:@"143461"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Norway" storeIdentifier:@"143457"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Osterreich" storeIdentifier:@"143445"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Pakistan" storeIdentifier:@"143477"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Panama" storeIdentifier:@"143485"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Peru" storeIdentifier:@"143507"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Phillipines" storeIdentifier:@"143474"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Poland" storeIdentifier:@"143478"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Portugal" storeIdentifier:@"143453"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Qatar" storeIdentifier:@"143498"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Romania" storeIdentifier:@"143487"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Russia" storeIdentifier:@"143469"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Saudi Arabia" storeIdentifier:@"143479"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Schweitz/Suisse" storeIdentifier:@"143459"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Singapore" storeIdentifier:@"143464"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Slovakia" storeIdentifier:@"143496"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Slovenia" storeIdentifier:@"143499"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"South Africa" storeIdentifier:@"143472"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Sri Lanka" storeIdentifier:@"143486"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Sweden" storeIdentifier:@"143456"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Taiwan" storeIdentifier:@"143470"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Thailand" storeIdentifier:@"143475"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Turkey" storeIdentifier:@"143480"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"United Arab Emirates" storeIdentifier:@"143481"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Venezuela" storeIdentifier:@"143502"] autorelease]];
	[tmpArray addObject:[[[ARAppStore alloc] initWithName:@"Vietnam" storeIdentifier:@"143471"] autorelease]];
	self.appStores = [tmpArray sortedArrayUsingSelector:@selector(compare:)];
}

- (void)updatePositions
{
	NSInteger i = 0;
	for (ARAppStoreApplication *app in applications)
	{
		app.position = i;
		i++;
	}
}

- (void)loadApplications
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	FMResultSet *ids = [database executeQuery:@"SELECT id FROM application"];
	while ([ids next])
	{
		NSInteger app_pk = [ids intForColumnIndex:0];
		ARAppStoreApplication *app = [[ARAppStoreApplication alloc] initWithPrimaryKey:app_pk database:database];
		[app hydrate];
		[tmpArray addObject:app];
		[app release];
	}
	[ids close];
	[applications addObjectsFromArray:[tmpArray sortedArrayUsingSelector:@selector(compareByPosition:)]];
	PSLog(@"Loaded %d apps", [applications count]);

	if ([applications count] == 0)
	{
		NSUInteger countBefore = [applications count];
#ifdef DEBUG
		[self setupTestData];
#endif
		// Start new user off with some default applications.
		[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"EventHorizon" appIdentifier:@"303143596"] autorelease]];
		[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"SleepOver" appIdentifier:@"286546049"] autorelease]];
		[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"vConqr" appIdentifier:@"290649401"] autorelease]];
		[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"Dialogues" appIdentifier:@"320166734"] autorelease]];
		PSLog(@"Added %d apps", [applications count]-countBefore);
	}
}

- (void)loadDetailsForApplication:(ARAppStoreApplication *)app
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	FMResultSet *ids = [database executeQuery:@"SELECT id FROM application_details WHERE app_identifier=?", app.appIdentifier];
	while ([ids next])
	{
		NSInteger appDetails_pk = [ids intForColumnIndex:0];
		ARAppStoreApplicationDetails *details = [[ARAppStoreApplicationDetails alloc] initWithPrimaryKey:appDetails_pk database:database];
		[tmpDict setObject:details forKey:details.storeIdentifier];
		[details release];
	}
	[ids close];
	[appDetails setObject:tmpDict forKey:app.appIdentifier];
}

- (void)loadReviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	FMResultSet *ids = [database executeQuery:@"SELECT id FROM application_review WHERE app_identifier=? AND store_identifier=? ORDER BY review_index", app.appIdentifier, store.storeIdentifier];
	while ([ids next])
	{
		NSInteger appReview_pk = [ids intForColumnIndex:0];
		ARAppStoreApplicationReview *review = [[ARAppStoreApplicationReview alloc] initWithPrimaryKey:appReview_pk database:database];
		[tmpArray addObject:review];
		[review release];
	}
	[ids close];
	// We have got an array with all reviews for the given app/store, now add it to dictionaryies.
	NSMutableDictionary *storeReviewsDictionary = [appReviews objectForKey:app.appIdentifier];
	if (storeReviewsDictionary == nil)
	{
		// We haven't loaded any review for this app yet, so create the storeReviews dictionary now.
		storeReviewsDictionary = [NSMutableDictionary dictionary];
		[appReviews setObject:storeReviewsDictionary forKey:app.appIdentifier];
	}

	[storeReviewsDictionary setObject:tmpArray forKey:store.storeIdentifier];
}


#pragma mark -
#pragma mark DEBUG methods

#ifdef DEBUG

- (void)setupTestData
{
	[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"vConqr" appIdentifier:@"290649401"] autorelease]];
	[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"Lux Touch" appIdentifier:@"292538570"] autorelease]];
	[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"Remote" appIdentifier:@"284417350"] autorelease]];
	[self addApplication:[[[ARAppStoreApplication alloc] initWithName:@"Texas Hold'em" appIdentifier:@"284602850"] autorelease]];
}

#endif

@end
