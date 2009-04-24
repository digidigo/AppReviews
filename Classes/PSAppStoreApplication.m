//
//  PSAppStoreApplication.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppReviewsStore.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
//#import "PSAppStoreReviews.h"
#import "FMDatabase.h"
#import "AppCriticsAppDelegate.h"
#import "PSLog.h"


@interface PSAppStoreApplication ()

@property (nonatomic, retain) FMDatabase *database;

@end


@implementation PSAppStoreApplication

@synthesize name, company, appIdentifier, defaultStoreIdentifier, position, primaryKey, database;

- (id)init
{
	return [self initWithName:nil company:nil appIdentifier:nil defaultStoreIdentifier:kDefaultStoreId];
}

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier
{
	return [self initWithName:nil company:nil appIdentifier:inAppIdentifier defaultStoreIdentifier:kDefaultStoreId];
}

- (id)initWithName:(NSString *)inName appIdentifier:(NSString *)inAppIdentifier
{
	return [self initWithName:inName company:nil appIdentifier:inAppIdentifier defaultStoreIdentifier:kDefaultStoreId];
}

// Designated initialiser.
- (id)initWithName:(NSString *)inName company:(NSString *)inCompany appIdentifier:(NSString *)inAppIdentifier defaultStoreIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.name = inName;
		self.company = inCompany;
		self.appIdentifier = inAppIdentifier;
		self.defaultStoreIdentifier = inStoreIdentifier;
		self.position = -1;
		self.database = nil;
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[company release];
	[appIdentifier release];
	[defaultStoreIdentifier release];
	[database release];
	[super dealloc];
}

// Creates the instance with primary key and non-hydration members are brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(FMDatabase *)db
{
    if (self = [super init])
	{
        primaryKey = pk;
        self.database = db;
		
		FMResultSet *row = [db executeQuery:@"SELECT app_identifier, position FROM application WHERE id=?", [NSNumber numberWithInteger:pk]];
		if (row && [row next])
		{
			self.appIdentifier = [row stringForColumnIndex:0];
			self.position = [row intForColumnIndex:1];
		}
		else
		{
			PSLogError(@"Failed to populate PSAppStoreApplication using primary key %d", pk);
			self.appIdentifier = nil;
			self.position = -1;
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
	if ([db executeUpdate:@"INSERT INTO application (name, company, app_identifier, default_store_identifier, position) VALUES (?,?,?,?,?)",
		 name, company, appIdentifier, defaultStoreIdentifier, [NSNumber numberWithInteger:position]])
	{
		primaryKey = [db lastInsertRowId];
	}
	else
	{
		NSString *message = [NSString stringWithFormat:@"Failed to insert PSAppStoreApplication into the database with message '%@'.", [db lastErrorMessage]];
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
		if (![database executeUpdate:@"UPDATE application SET name=?, company=?, app_identifier=?, default_store_identifier=?, position=? WHERE id=?", name, company, appIdentifier, defaultStoreIdentifier, [NSNumber numberWithInteger:position], [NSNumber numberWithInteger:primaryKey]])
		{
			NSString *message = [NSString stringWithFormat:@"Failed to save PSAppStoreApplication with message '%@'.", [database lastErrorMessage]];
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
	
	FMResultSet *row = [database executeQuery:@"SELECT name, company, default_store_identifier FROM application WHERE id=?", [NSNumber numberWithInteger:primaryKey]];
	if (row && [row next])
	{
		self.name = [row stringForColumnIndex:0];
		self.company = [row stringForColumnIndex:1];
		self.defaultStoreIdentifier = [row stringForColumnIndex:2];
	}
	else
	{
		PSLogError(@"Failed to hydrate PSAppStoreApplication using primary key %d", primaryKey);
		self.name = nil;
		self.company = nil;
		self.defaultStoreIdentifier = kDefaultStoreId;
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
	[name release];
	name = nil;
	[company release];
	company = nil;
	[defaultStoreIdentifier release];
	defaultStoreIdentifier = nil;
    // Update the object state with respect to hydration.
    hydrated = NO;
}

// Remove the object completely from the database. In memory deletion to follow...
- (void)deleteFromDatabase
{
	if (![database executeUpdate:@"DELETE FROM application WHERE id=?", [NSNumber numberWithInteger:primaryKey]])
	{
		NSString *message = [NSString stringWithFormat:@"Failed to delete PSAppStoreApplication with message '%@'.", [database lastErrorMessage]];
		PSLogError(message);
		NSAssert(0, message);
	}
}

- (NSComparisonResult)compareByPosition:(PSAppStoreApplication *)other
{
	if (self.position < other.position)
		return NSOrderedAscending;
	else if (self.position > other.position)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
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

- (void)setName:(NSString *)aString
{
    if ((!name && !aString) || (name && aString && [name isEqualToString:aString]))
		return;
	
    dirty = YES;
    [name release];
    name = [aString copy];
}

- (void)setCompany:(NSString *)aString
{
    if ((!company && !aString) || (company && aString && [company isEqualToString:aString]))
		return;
	
    dirty = YES;
    [company release];
    company = [aString copy];
}

- (void)setAppIdentifier:(NSString *)aString
{
    if ((!appIdentifier && !aString) || (appIdentifier && aString && [appIdentifier isEqualToString:aString]))
		return;
	
    dirty = YES;
    [appIdentifier release];
    appIdentifier = [aString copy];
}

- (void)setDefaultStoreIdentifier:(NSString *)aString
{
    if ((!defaultStoreIdentifier && !aString) || (defaultStoreIdentifier && aString && [defaultStoreIdentifier isEqualToString:aString]))
		return;
	
    dirty = YES;
    [defaultStoreIdentifier release];
    defaultStoreIdentifier = [aString copy];
}

- (void)setPosition:(NSInteger)anInt
{
	if (position == anInt)
		return;
	
    dirty = YES;
	position = anInt;
}

@end
