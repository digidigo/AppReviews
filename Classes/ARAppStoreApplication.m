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
#import "ARAppStoreApplication.h"
#import "ARAppStoreUpdateOperation.h"
#import "ARAppStore.h"
#import "ARAppStoreApplicationDetails.h"
#import "FMDatabase.h"
#import "AppReviewsAppDelegate.h"
#import "PSLog.h"


@interface ARAppStoreApplication ()

@property (nonatomic, retain) FMDatabase *database;

@end


@implementation ARAppStoreApplication

@synthesize name, company, appIdentifier, defaultStoreIdentifier, position, primaryKey, database, updateOperationsCount;

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
		updateOperationsQueue = [[NSOperationQueue alloc] init];
		updateOperationsCount = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedOperationEnded:) name:kARAppStoreUpdateOperationDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedOperationEnded:) name:kARAppStoreUpdateOperationDidFailNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[name release];
	[company release];
	[appIdentifier release];
	[defaultStoreIdentifier release];
	[database release];
	[updateOperationsQueue release];
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
			PSLogError(@"Failed to populate ARAppStoreApplication using primary key %d", pk);
			self.appIdentifier = nil;
			self.position = -1;
		}
		[row close];
        dirty = NO;
		hydrated = NO;
		updateOperationsQueue = [[NSOperationQueue alloc] init];
		updateOperationsCount = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedOperationEnded:) name:kARAppStoreUpdateOperationDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedOperationEnded:) name:kARAppStoreUpdateOperationDidFailNotification object:nil];
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
		NSString *message = [NSString stringWithFormat:@"Failed to insert ARAppStoreApplication into the database with message '%@'.", [db lastErrorMessage]];
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
			NSString *message = [NSString stringWithFormat:@"Failed to save ARAppStoreApplication with message '%@'.", [database lastErrorMessage]];
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
		PSLogError(@"Failed to hydrate ARAppStoreApplication using primary key %d", primaryKey);
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
		NSString *message = [NSString stringWithFormat:@"Failed to delete ARAppStoreApplication with message '%@'.", [database lastErrorMessage]];
		PSLogError(message);
		NSAssert(0, message);
	}
}

- (NSComparisonResult)compareByPosition:(ARAppStoreApplication *)other
{
	if (self.position < other.position)
		return NSOrderedAscending;
	else if (self.position > other.position)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (void)cancelOperationsForApplicationDetails:(ARAppStoreApplicationDetails *)appStoreDetails
{
	@synchronized(self)
	{
		[updateOperationsQueue setSuspended:YES];

		NSArray *updateOperations = [updateOperationsQueue operations];
		for (ARAppStoreUpdateOperation *op in updateOperations)
		{
			if ([op.appDetails.appIdentifier isEqualToString:appStoreDetails.appIdentifier] &&
				[op.appDetails.storeIdentifier isEqualToString:appStoreDetails.storeIdentifier] &&
				![op isCancelled] &&
				![op isExecuting])
			{
				[op	cancel];
				updateOperationsCount--;
			}
		}

		[updateOperationsQueue setSuspended:NO];
	}
}

- (void)cancelAllOperations
{
	PSLogDebug(@"");
	@synchronized(self)
	{
		[updateOperationsQueue cancelAllOperations];
		updateOperationsCount = 0;
	}
}

- (void)suspendAllOperations
{
	PSLogDebug(@"");
	[updateOperationsQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
	PSLogDebug(@"");
	[updateOperationsQueue setSuspended:NO];
}

- (void)addUpdateOperation:(ARAppStoreUpdateOperation *)op
{
	@synchronized(self)
	{
		PSLogDebug(@"");
		updateOperationsCount++;
		[updateOperationsQueue addOperation:op];
	}
}

- (void)updatedOperationEnded:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	@synchronized(self)
	{
		// Check that this notification was for our application.
		ARAppStoreApplicationDetails *details = (ARAppStoreApplicationDetails *) [notification object];
		if ([details.appIdentifier isEqualToString:appIdentifier])
		{
			if (updateOperationsCount > 0)
				updateOperationsCount--;
		}
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
