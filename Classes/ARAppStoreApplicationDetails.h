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

#import <Foundation/Foundation.h>
#import "ACAppReviewsStore.h"


typedef enum
{
	ACAppStoreStateDefault,
	ACAppStoreStatePending,
	ACAppStoreStateProcessing,
	ACAppStoreStateFailed
} ACAppStoreState;


@class FMDatabase;
@class ACAppStoreApplication;
@class ACAppStore;


@interface ACAppStoreApplicationDetails : NSObject
{
	// Persistent members.
	NSString *appIdentifier;
	NSString *storeIdentifier;
	NSString *category;
	NSString *categoryIdentifier;
	NSUInteger ratingCountAll;
	NSUInteger ratingCountAll5Stars;
	NSUInteger ratingCountAll4Stars;
	NSUInteger ratingCountAll3Stars;
	NSUInteger ratingCountAll2Stars;
	NSUInteger ratingCountAll1Star;
	NSUInteger ratingCountCurrent;
	NSUInteger ratingCountCurrent5Stars;
	NSUInteger ratingCountCurrent4Stars;
	NSUInteger ratingCountCurrent3Stars;
	NSUInteger ratingCountCurrent2Stars;
	NSUInteger ratingCountCurrent1Star;
	double ratingAll;
	double ratingCurrent;
	NSUInteger reviewCountAll;
	NSUInteger reviewCountCurrent;
	ACReviewsSortOrder lastSortOrder;
	NSDate *lastUpdated;

	// Persistent members (dehydrated).
	NSString *released;
	NSString *appVersion;
	NSString *appSize;
	NSString *localPrice;
	NSString *appName;
	NSString *appCompany;
	NSString *companyURL;
	NSString *companyURLTitle;
	NSString *supportURL;
	NSString *supportURLTitle;

	// Non-persistent members.
	BOOL hasNewRatings;
	BOOL hasNewReviews;
	ACAppStoreState state;

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
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *categoryIdentifier;
@property (nonatomic, assign) NSUInteger ratingCountAll;
@property (nonatomic, assign) NSUInteger ratingCountAll5Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll4Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll3Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll2Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll1Star;
@property (nonatomic, assign) NSUInteger ratingCountCurrent;
@property (nonatomic, assign) NSUInteger ratingCountCurrent5Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent4Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent3Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent2Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent1Star;
@property (nonatomic, assign) double ratingAll;
@property (nonatomic, assign) double ratingCurrent;
@property (nonatomic, assign) NSUInteger reviewCountAll;
@property (nonatomic, assign) NSUInteger reviewCountCurrent;
@property (nonatomic, assign) ACReviewsSortOrder lastSortOrder;
@property (nonatomic, copy) NSDate *lastUpdated;
@property (nonatomic, copy) NSString *released;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appSize;
@property (nonatomic, copy) NSString *localPrice;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appCompany;
@property (nonatomic, copy) NSString *companyURL;
@property (nonatomic, copy) NSString *companyURLTitle;
@property (nonatomic, copy) NSString *supportURL;
@property (nonatomic, copy) NSString *supportURLTitle;

@property (nonatomic, assign) BOOL hasNewRatings;
@property (nonatomic, assign) BOOL hasNewReviews;
@property (assign) ACAppStoreState state;
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
