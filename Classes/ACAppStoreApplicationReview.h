//
//  PSAppStoreApplicationReview.h
//  AppCritics
//
//  Created by Charles Gamble on 09/04/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FMDatabase;


@interface PSAppStoreApplicationReview : NSObject
{
	// Persistent members.
	NSString *appIdentifier;
	NSString *storeIdentifier;
	NSUInteger index;
	double rating;

	// Persistent members (dehydrated).
	NSString *reviewer;
	NSString *summary;
	NSString *detail;
	NSString *appVersion;
	NSString *reviewDate;

    // Opaque reference to the underlying database.
    FMDatabase *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Hydrated tracks whether attribute data is in the object or the database.
    BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *reviewer;
@property (nonatomic, assign) double rating;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *reviewDate;
@property (nonatomic, assign, readonly) NSInteger primaryKey;

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier;

// Creates the object with primary key and non-hydration members are brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(FMDatabase *)db;
// Inserts the object into the database and stores its primary key.
- (void)insertIntoDatabase:(FMDatabase *)db;
// Write any changes to the database.
- (void)save;
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate;
// Flushes all but the primary key and non-hydration members out to the database.
- (void)dehydrate;
// Remove the object completely from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

@end
