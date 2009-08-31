//
//  ACAppStoreApplicationDetails.m
//  AppCritics
//
//  Created by Charles Gamble on 15/03/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "ACAppStoreApplicationDetails.h"
#import "ACAppStoreApplication.h"
#import "ACAppStore.h"
#import "AppCriticsAppDelegate.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "FMDatabase.h"
#import "PSLog.h"


@interface ACAppStoreApplicationDetails ()

@property (nonatomic, retain) FMDatabase *database;

@end


@implementation ACAppStoreApplicationDetails

@synthesize appIdentifier, storeIdentifier, category, categoryIdentifier, ratingCountAll, ratingCountCurrent, ratingAll, ratingCurrent, reviewCountAll, reviewCountCurrent, lastSortOrder, lastUpdated;
@synthesize released, appVersion, appSize, localPrice, appName, appCompany, companyURL, companyURLTitle, supportURL, supportURLTitle;
@synthesize ratingCountAll5Stars, ratingCountAll4Stars, ratingCountAll3Stars, ratingCountAll2Stars, ratingCountAll1Star;
@synthesize ratingCountCurrent5Stars, ratingCountCurrent4Stars, ratingCountCurrent3Stars, ratingCountCurrent2Stars, ratingCountCurrent1Star;
@synthesize hasNewRatings, hasNewReviews, state, primaryKey, database;

- (id)init
{
	return [self initWithAppIdentifier:nil storeIdentifier:nil];
}

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.appIdentifier = inAppIdentifier;
		self.storeIdentifier = inStoreIdentifier;
		self.category = nil;
		self.categoryIdentifier = nil;
		self.ratingCountAll = 0;
		self.ratingCountAll5Stars = 0;
		self.ratingCountAll4Stars = 0;
		self.ratingCountAll3Stars = 0;
		self.ratingCountAll2Stars = 0;
		self.ratingCountAll1Star = 0;
		self.ratingCountCurrent = 0;
		self.ratingCountCurrent5Stars = 0;
		self.ratingCountCurrent4Stars = 0;
		self.ratingCountCurrent3Stars = 0;
		self.ratingCountCurrent2Stars = 0;
		self.ratingCountCurrent1Star = 0;
		self.ratingAll = 0.0;
		self.ratingCurrent = 0.0;
		self.reviewCountAll = 0;
		self.reviewCountCurrent = 0;
		self.released = nil;
		self.appVersion = nil;
		self.appSize = nil;
		self.localPrice = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.companyURL = nil;
		self.companyURLTitle = nil;
		self.supportURL = nil;
		self.supportURLTitle = nil;
		self.lastSortOrder = (ACReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		self.lastUpdated = [NSDate distantPast];
		self.hasNewRatings = NO;
		self.hasNewReviews = NO;
		self.state = ACAppStoreStateDefault;
		self.database = nil;
	}
	return self;
}

- (void)dealloc
{
	[appIdentifier release];
	[storeIdentifier release];
	[category release];
	[categoryIdentifier release];
	[released release];
	[appVersion release];
	[appSize release];
	[localPrice release];
	[appName release];
	[appCompany release];
	[companyURL release];
	[companyURLTitle release];
	[supportURL release];
	[supportURLTitle release];
	[lastUpdated release];
	[database release];
	[super dealloc];
}

// Creates the object with primary key and non-hydration members are brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(FMDatabase *)db
{
    if (self = [super init])
	{
        primaryKey = pk;
        self.database = db;
		self.hasNewRatings = NO;
		self.hasNewReviews = NO;
		self.state = ACAppStoreStateDefault;

		FMResultSet *row = [db executeQuery:@"SELECT app_identifier, store_identifier, category, category_identifier, rating_count_all, rating_count_all_5stars, rating_count_all_4stars, rating_count_all_3stars, rating_count_all_2stars, rating_count_all_1star, rating_count_current, rating_count_current_5stars, rating_count_current_4stars, rating_count_current_3stars, rating_count_current_2stars, rating_count_current_1star, rating_all, rating_current, review_count_all, review_count_current, last_sort_order, last_updated FROM application_details WHERE id=?", [NSNumber numberWithInteger:pk]];
		if (row && [row next])
		{
			self.appIdentifier = [row stringForColumnIndex:0];
			self.storeIdentifier = [row stringForColumnIndex:1];
			self.category = [row stringForColumnIndex:2];
			self.categoryIdentifier = [row stringForColumnIndex:3];
			self.ratingCountAll = [row intForColumnIndex:4];
			self.ratingCountAll5Stars = [row intForColumnIndex:5];
			self.ratingCountAll4Stars = [row intForColumnIndex:6];
			self.ratingCountAll3Stars = [row intForColumnIndex:7];
			self.ratingCountAll2Stars = [row intForColumnIndex:8];
			self.ratingCountAll1Star = [row intForColumnIndex:9];
			self.ratingCountCurrent = [row intForColumnIndex:10];
			self.ratingCountCurrent5Stars = [row intForColumnIndex:11];
			self.ratingCountCurrent4Stars = [row intForColumnIndex:12];
			self.ratingCountCurrent3Stars = [row intForColumnIndex:13];
			self.ratingCountCurrent2Stars = [row intForColumnIndex:14];
			self.ratingCountCurrent1Star = [row intForColumnIndex:15];
			self.ratingAll = [row doubleForColumnIndex:16];
			self.ratingCurrent = [row doubleForColumnIndex:17];
			self.reviewCountAll = [row intForColumnIndex:18];
			self.reviewCountCurrent = [row intForColumnIndex:19];
			self.lastSortOrder = (ACReviewsSortOrder) [row intForColumnIndex:20];
			self.lastUpdated = [row dateForColumnIndex:21];
		}
		else
		{
			PSLogError(@"Failed to populate ACAppStoreApplicationDetails using primary key %d", pk);
			self.appIdentifier = nil;
			self.storeIdentifier = nil;
			self.category = nil;
			self.categoryIdentifier = nil;
			self.ratingCountAll = 0;
			self.ratingCountAll5Stars = 0;
			self.ratingCountAll4Stars = 0;
			self.ratingCountAll3Stars = 0;
			self.ratingCountAll2Stars = 0;
			self.ratingCountAll1Star = 0;
			self.ratingCountCurrent = 0;
			self.ratingCountCurrent5Stars = 0;
			self.ratingCountCurrent4Stars = 0;
			self.ratingCountCurrent3Stars = 0;
			self.ratingCountCurrent2Stars = 0;
			self.ratingCountCurrent1Star = 0;
			self.ratingAll = 0.0;
			self.ratingCurrent = 0.0;
			self.reviewCountAll = 0;
			self.reviewCountCurrent = 0;
			self.lastSortOrder = (ACReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
			self.lastUpdated = nil;
		}
		[row close];
        dirty = NO;
		hydrated = NO;
    }
    return self;
}

// Inserts the object into the database and stores its primary key.
- (void)insertIntoDatabase:(FMDatabase *)db
{
	self.database = db;

	if ([db executeUpdate:@"INSERT INTO application_details (app_identifier, store_identifier, category, category_identifier, rating_count_all, rating_count_all_5stars, rating_count_all_4stars, rating_count_all_3stars, rating_count_all_2stars, rating_count_all_1star, rating_count_current, rating_count_current_5stars, rating_count_current_4stars, rating_count_current_3stars, rating_count_current_2stars, rating_count_current_1star, rating_all, rating_current, review_count_all, review_count_current, last_sort_order, last_updated, released, version, size, price, name, company, company_url, company_url_title, support_url, support_url_title) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
		 appIdentifier,
		 storeIdentifier,
		 category,
		 categoryIdentifier,
		 [NSNumber numberWithInteger:ratingCountAll],
		 [NSNumber numberWithInteger:ratingCountAll5Stars],
		 [NSNumber numberWithInteger:ratingCountAll4Stars],
		 [NSNumber numberWithInteger:ratingCountAll3Stars],
		 [NSNumber numberWithInteger:ratingCountAll2Stars],
		 [NSNumber numberWithInteger:ratingCountAll1Star],
		 [NSNumber numberWithInteger:ratingCountCurrent],
		 [NSNumber numberWithInteger:ratingCountCurrent5Stars],
		 [NSNumber numberWithInteger:ratingCountCurrent4Stars],
		 [NSNumber numberWithInteger:ratingCountCurrent3Stars],
		 [NSNumber numberWithInteger:ratingCountCurrent2Stars],
		 [NSNumber numberWithInteger:ratingCountCurrent1Star],
		 [NSNumber numberWithDouble:ratingAll],
		 [NSNumber numberWithDouble:ratingCurrent],
		 [NSNumber numberWithInteger:reviewCountAll],
		 [NSNumber numberWithInteger:reviewCountCurrent],
		 [NSNumber numberWithInteger:lastSortOrder],
		 lastUpdated,
		 released,
		 appVersion,
		 appSize,
		 localPrice,
		 appName,
		 appCompany,
		 companyURL,
		 companyURLTitle,
		 supportURL,
		 supportURLTitle])
	{
		primaryKey = [db lastInsertRowId];
	}
	else
	{
		NSString *message = [NSString stringWithFormat:@"Failed to insert ACAppStoreApplicationDetails into the database with message '%@'.", [db lastErrorMessage]];
		PSLogError(message);
        NSAssert(0, message);
	}

    // All data for the application is already in memory, but has not been written to the database.
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory.
    hydrated = YES;
}

// Write any changes to the database.
- (void)save
{
    if (dirty)
	{
		if (![database executeUpdate:@"UPDATE application_details SET app_identifier=?, store_identifier=?, category=?, category_identifier=?, rating_count_all=?, rating_count_all_5stars=?, rating_count_all_4stars=?, rating_count_all_3stars=?, rating_count_all_2stars=?, rating_count_all_1star=?, rating_count_current=?, rating_count_current_5stars=?, rating_count_current_4stars=?, rating_count_current_3stars=?, rating_count_current_2stars=?, rating_count_current_1star=?, rating_all=?, rating_current=?, review_count_all=?, review_count_current=?, last_sort_order=?, last_updated=?, released=?, version=?, size=?, price=?, name=?, company=?, company_url=?, company_url_title=?, support_url=?, support_url_title=? WHERE id=?",
			  appIdentifier,
			  storeIdentifier,
			  category,
			  categoryIdentifier,
			  [NSNumber numberWithInteger:ratingCountAll],
			  [NSNumber numberWithInteger:ratingCountAll5Stars],
			  [NSNumber numberWithInteger:ratingCountAll4Stars],
			  [NSNumber numberWithInteger:ratingCountAll3Stars],
			  [NSNumber numberWithInteger:ratingCountAll2Stars],
			  [NSNumber numberWithInteger:ratingCountAll1Star],
			  [NSNumber numberWithInteger:ratingCountCurrent],
			  [NSNumber numberWithInteger:ratingCountCurrent5Stars],
			  [NSNumber numberWithInteger:ratingCountCurrent4Stars],
			  [NSNumber numberWithInteger:ratingCountCurrent3Stars],
			  [NSNumber numberWithInteger:ratingCountCurrent2Stars],
			  [NSNumber numberWithInteger:ratingCountCurrent1Star],
			  [NSNumber numberWithDouble:ratingAll],
			  [NSNumber numberWithDouble:ratingCurrent],
			  [NSNumber numberWithInteger:reviewCountAll],
			  [NSNumber numberWithInteger:reviewCountCurrent],
			  [NSNumber numberWithInteger:lastSortOrder],
			  lastUpdated,
			  released,
			  appVersion,
			  appSize,
			  localPrice,
			  appName,
			  appCompany,
			  companyURL,
			  companyURLTitle,
			  supportURL,
			  supportURLTitle,
			  [NSNumber numberWithInteger:primaryKey]])
		{
			NSString *message = [NSString stringWithFormat:@"Failed to save ACAppStoreApplicationDetails with message '%@'.", [database lastErrorMessage]];
			PSLogError(message);
			NSAssert(0, message);
		}

        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate
{
    // Check if action is necessary.
    if (hydrated)
		return;

	FMResultSet *row = [database executeQuery:@"SELECT released, version, size, price, name, company, company_url, company_url_title, support_url, support_url_title FROM application_details WHERE id=?", [NSNumber numberWithInteger:primaryKey]];
	if (row && [row next])
	{
		self.released = [row stringForColumnIndex:0];
		self.appVersion = [row stringForColumnIndex:1];
		self.appSize = [row stringForColumnIndex:2];
		self.localPrice = [row stringForColumnIndex:3];
		self.appName = [row stringForColumnIndex:4];
		self.appCompany = [row stringForColumnIndex:5];
		self.companyURL = [row stringForColumnIndex:6];
		self.companyURLTitle = [row stringForColumnIndex:7];
		self.supportURL = [row stringForColumnIndex:8];
		self.supportURLTitle = [row stringForColumnIndex:9];
	}
	else
	{
		PSLogError(@"Failed to hydrate ACAppStoreApplicationDetails using primary key %d", primaryKey);
		self.released = nil;
		self.appVersion = nil;
		self.appSize = nil;
		self.localPrice = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.companyURL = nil;
		self.companyURLTitle = nil;
		self.supportURL = nil;
		self.supportURLTitle = nil;
	}
	[row close];

    // Update object state with respect to hydration.
    hydrated = YES;
}

// Flushes all but the primary key and non-hydration members out to the database.
- (void)dehydrate
{
	// Write any changes to the database.
	[self save];

    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them
    // if dehydrate is called multiple times.
	[released release];
	released = nil;
	[appVersion release];
	appVersion = nil;
	[appSize release];
	appSize = nil;
	[localPrice release];
	localPrice = nil;
	[appName release];
	appName = nil;
	[appCompany release];
	appCompany = nil;
	[companyURL release];
	companyURL = nil;
	[companyURLTitle release];
	companyURLTitle = nil;
	[supportURL release];
	supportURL = nil;
	[supportURLTitle release];
	supportURLTitle = nil;
    // Update the object state with respect to hydration.
    hydrated = NO;
}

// Remove the object completely from the database. In memory deletion to follow...
- (void)deleteFromDatabase
{
	if (![database executeUpdate:@"DELETE FROM application_details WHERE id=?", [NSNumber numberWithInteger:primaryKey]])
	{
		NSString *message = [NSString stringWithFormat:@"Failed to delete ACAppStoreApplicationDetails with message '%@'.", [database lastErrorMessage]];
		PSLogError(message);
		NSAssert(0, message);
	}
}


#pragma mark -
#pragma mark Accessors

// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers,
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate
// the encapsulation of the owning object.

- (void)setAppIdentifier:(NSString *)aString
{
	if ((!appIdentifier && !aString) || (appIdentifier && aString && [appIdentifier isEqualToString:aString]))
		return;

	dirty = YES;
	[appIdentifier release];
	appIdentifier = [aString copy];
}

- (void)setStoreIdentifier:(NSString *)aString
{
	if ((!storeIdentifier && !aString) || (storeIdentifier && aString && [storeIdentifier isEqualToString:aString]))
		return;

	dirty = YES;
	[storeIdentifier release];
	storeIdentifier = [aString copy];
}

- (void)setCategory:(NSString *)aString
{
	if ((!category && !aString) || (category && aString && [category isEqualToString:aString]))
		return;

	dirty = YES;
	[category release];
	category = [aString copy];
}

- (void)setCategoryIdentifier:(NSString *)aString
{
	if ((!categoryIdentifier && !aString) || (categoryIdentifier && aString && [categoryIdentifier isEqualToString:aString]))
		return;

	dirty = YES;
	[categoryIdentifier release];
	categoryIdentifier = [aString copy];
}

- (void)setRatingCountAll:(NSUInteger)anInt
{
	if (ratingCountAll == anInt)
		return;

	dirty = YES;
	ratingCountAll = anInt;
}

- (void)setRatingCountAll5Stars:(NSUInteger)anInt
{
	if (ratingCountAll5Stars == anInt)
		return;

	dirty = YES;
	ratingCountAll5Stars = anInt;
}

- (void)setRatingCountAll4Stars:(NSUInteger)anInt
{
	if (ratingCountAll4Stars == anInt)
		return;

	dirty = YES;
	ratingCountAll4Stars = anInt;
}

- (void)setRatingCountAll3Stars:(NSUInteger)anInt
{
	if (ratingCountAll3Stars == anInt)
		return;

	dirty = YES;
	ratingCountAll3Stars = anInt;
}

- (void)setRatingCountAll2Stars:(NSUInteger)anInt
{
	if (ratingCountAll2Stars == anInt)
		return;

	dirty = YES;
	ratingCountAll2Stars = anInt;
}

- (void)setRatingCountAll1Star:(NSUInteger)anInt
{
	if (ratingCountAll1Star == anInt)
		return;

	dirty = YES;
	ratingCountAll1Star = anInt;
}

- (void)setRatingCountCurrent:(NSUInteger)anInt
{
	if (ratingCountCurrent == anInt)
		return;

	dirty = YES;
	ratingCountCurrent = anInt;
}

- (void)setRatingCountCurrent5Stars:(NSUInteger)anInt
{
	if (ratingCountCurrent5Stars == anInt)
		return;

	dirty = YES;
	ratingCountCurrent5Stars = anInt;
}

- (void)setRatingCountCurrent4Stars:(NSUInteger)anInt
{
	if (ratingCountCurrent4Stars == anInt)
		return;

	dirty = YES;
	ratingCountCurrent4Stars = anInt;
}

- (void)setRatingCountCurrent3Stars:(NSUInteger)anInt
{
	if (ratingCountCurrent3Stars == anInt)
		return;

	dirty = YES;
	ratingCountCurrent3Stars = anInt;
}

- (void)setRatingCountCurrent2Stars:(NSUInteger)anInt
{
	if (ratingCountCurrent2Stars == anInt)
		return;

	dirty = YES;
	ratingCountCurrent2Stars = anInt;
}

- (void)setRatingCountCurrent1Star:(NSUInteger)anInt
{
	if (ratingCountCurrent1Star == anInt)
		return;

	dirty = YES;
	ratingCountCurrent1Star = anInt;
}

- (void)setRatingAll:(double)aDouble
{
	dirty = YES;
	ratingAll = aDouble;
}

- (void)setRatingCurrent:(double)aDouble
{
	dirty = YES;
	ratingCurrent = aDouble;
}

- (void)setReviewCountAll:(NSUInteger)anInt
{
	if (reviewCountAll == anInt)
		return;

	dirty = YES;
	reviewCountAll = anInt;
}

- (void)setReviewCountCurrent:(NSUInteger)anInt
{
	if (reviewCountCurrent == anInt)
		return;

	dirty = YES;
	reviewCountCurrent = anInt;
}

- (void)setLastSortOrder:(ACReviewsSortOrder)aSortOrder
{
	if (lastSortOrder == aSortOrder)
		return;

	dirty = YES;
	lastSortOrder = aSortOrder;
}

- (void)setLastUpdated:(NSDate *)aDate
{
	if ((!lastUpdated && !aDate) || (lastUpdated && aDate && [lastUpdated isEqualToDate:aDate]))
		return;

	dirty = YES;
	[lastUpdated release];
	lastUpdated = [aDate copy];
}

- (void)setReleased:(NSString *)aString
{
	if ((!released && !aString) || (released && aString && [released isEqualToString:aString]))
		return;

	dirty = YES;
	[released release];
	released = [aString copy];
}

- (void)setAppVersion:(NSString *)aString
{
	if ((!appVersion && !aString) || (appVersion && aString && [appVersion isEqualToString:aString]))
		return;

	dirty = YES;
	[appVersion release];
	appVersion = [aString copy];
}

- (void)setAppSize:(NSString *)aString
{
	if ((!appSize && !aString) || (appSize && aString && [appSize isEqualToString:aString]))
		return;

	dirty = YES;
	[appSize release];
	appSize = [aString copy];
}

- (void)setLocalPrice:(NSString *)aString
{
	if ((!localPrice && !aString) || (localPrice && aString && [localPrice isEqualToString:aString]))
		return;

	dirty = YES;
	[localPrice release];
	localPrice = [aString copy];
}

- (void)setAppName:(NSString *)aString
{
	if ((!appName && !aString) || (appName && aString && [appName isEqualToString:aString]))
		return;

	dirty = YES;
	[appName release];
	appName = [aString copy];
}

- (void)setAppCompany:(NSString *)aString
{
	if ((!appCompany && !aString) || (appCompany && aString && [appCompany isEqualToString:aString]))
		return;

	dirty = YES;
	[appCompany release];
	appCompany = [aString copy];
}

- (void)setCompanyURL:(NSString *)aString
{
	if ((!companyURL && !aString) || (companyURL && aString && [companyURL isEqualToString:aString]))
		return;

	dirty = YES;
	[companyURL release];
	companyURL = [aString copy];
}

- (void)setCompanyURLTitle:(NSString *)aString
{
	if ((!companyURLTitle && !aString) || (companyURLTitle && aString && [companyURLTitle isEqualToString:aString]))
		return;

	dirty = YES;
	[companyURLTitle release];
	companyURLTitle = [aString copy];
}

- (void)setSupportURL:(NSString *)aString
{
	if ((!supportURL && !aString) || (supportURL && aString && [supportURL isEqualToString:aString]))
		return;

	dirty = YES;
	[supportURL release];
	supportURL = [aString copy];
}

- (void)setSupportURLTitle:(NSString *)aString
{
	if ((!supportURLTitle && !aString) || (supportURLTitle && aString && [supportURLTitle isEqualToString:aString]))
		return;

	dirty = YES;
	[supportURLTitle release];
	supportURLTitle = [aString copy];
}

@end
