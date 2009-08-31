//
//  PSAppReviewsStore.h
//  AppCritics
//
//  Created by Charles Gamble on 13/03/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
	PSMostHelpfulSortOrder = 1,
	PSMostFavorableSortOrder,
	PSMostCriticalSortOrder,
	PSMostRecentSortOrder
} PSReviewsSortOrder;


@class FMDatabase;
@class PSAppStore;
@class PSAppStoreApplication;
@class PSAppStoreApplicationDetails;


/**
 * Singleton class to encapsulate model data access.
 */
@interface PSAppReviewsStore : NSObject
{
	FMDatabase *database;
	NSArray *appStores;
	NSMutableArray *applications;
	NSMutableDictionary *appDetails;	// dict(appId => dict(storeId => details))
	NSMutableDictionary *appReviews;	// dict(appId => dict(storeId => array(review)))
}

@property (retain) NSArray *appStores;

/**
 * Get the singleton instance.
 */
+ (PSAppReviewsStore *)sharedInstance;

- (BOOL)save;
- (void)close;

- (PSAppStore *)storeForIdentifier:(NSString *)storeIdentifier;
- (NSArray *)applications;
- (PSAppStoreApplication *)applicationForIdentifier:(NSString *)appIdentifier;
- (PSAppStoreApplication *)applicationAtIndex:(NSUInteger)index;
- (NSUInteger)applicationCount;
- (void)addApplication:(PSAppStoreApplication *)app;
- (void)addApplication:(PSAppStoreApplication *)app atIndex:(NSUInteger)index;
- (void)moveApplicationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeApplication:(PSAppStoreApplication *)app;
- (void)resetDetailsForApplication:(PSAppStoreApplication *)app;
- (PSAppStoreApplicationDetails *)detailsForApplication:(PSAppStoreApplication *)app inStore:(PSAppStore *)store;
- (void)setReviews:(NSArray *)reviews forApplication:(PSAppStoreApplication *)app inStore:(PSAppStore *)store;
- (NSArray *)reviewsForApplication:(PSAppStoreApplication *)app inStore:(PSAppStore *)store;

@end
