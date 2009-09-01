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


// Default to the US store as the apps "home store" (for looking up name, company, etc).
#define kDefaultStoreId	@"143441"


@class FMDatabase;
@class ACAppStoreUpdateOperation;


@interface ACAppStoreApplication : NSObject
{
	// Persistent members.
	NSString *appIdentifier;
	NSInteger position;
	// Persistent members (dehydrated).
	NSString *name;
	NSString *company;
	NSString *defaultStoreIdentifier;

    // Opaque reference to the underlying database.
    FMDatabase *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Hydrated tracks whether attribute data is in the object or the database.
    BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
	// NSOperationQueue for all downloads related to this app.
	NSOperationQueue *updateOperationsQueue;
	NSUInteger updateOperationsCount;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *defaultStoreIdentifier;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign, readonly) NSInteger primaryKey;
@property (nonatomic, readonly) NSUInteger updateOperationsCount;

- (id)init;
- (id)initWithAppIdentifier:(NSString *)inAppIdentifier;
- (id)initWithName:(NSString *)inName appIdentifier:(NSString *)inAppIdentifier;
- (id)initWithName:(NSString *)inName company:(NSString *)inCompany appIdentifier:(NSString *)inAppIdentifier defaultStoreIdentifier:(NSString *)inStoreIdentifier;

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
// Manage the operations queue for this application.
- (void)cancelAllOperations;
- (void)cancelOperationsForApplicationDetails:(ACAppStoreApplicationDetails *)appStoreDetails;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)addUpdateOperation:(ACAppStoreUpdateOperation *)op;

@end
