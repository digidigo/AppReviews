//
//  ACAppReviewsStore.h
//  AppCritics
//
//  Created by Charles Gamble on 13/03/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
	ACMostHelpfulSortOrder = 1,
	ACMostFavorableSortOrder,
	ACMostCriticalSortOrder,
	ACMostRecentSortOrder
} ACReviewsSortOrder;


@class FMDatabase;
@class ACAppStore;
@class ACAppStoreApplication;
@class ACAppStoreApplicationDetails;


/**
 * Singleton class to encapsulate model data access.
 */
@interface ACAppReviewsStore : NSObject
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
+ (ACAppReviewsStore *)sharedInstance;

- (BOOL)save;
- (void)close;

- (ACAppStore *)storeForIdentifier:(NSString *)storeIdentifier;
- (NSArray *)applications;
- (ACAppStoreApplication *)applicationForIdentifier:(NSString *)appIdentifier;
- (ACAppStoreApplication *)applicationAtIndex:(NSUInteger)index;
- (NSUInteger)applicationCount;
- (void)addApplication:(ACAppStoreApplication *)app;
- (void)addApplication:(ACAppStoreApplication *)app atIndex:(NSUInteger)index;
- (void)moveApplicationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeApplication:(ACAppStoreApplication *)app;
- (void)resetDetailsForApplication:(ACAppStoreApplication *)app;
- (ACAppStoreApplicationDetails *)detailsForApplication:(ACAppStoreApplication *)app inStore:(ACAppStore *)store;
- (void)setReviews:(NSArray *)reviews forApplication:(ACAppStoreApplication *)app inStore:(ACAppStore *)store;
- (NSArray *)reviewsForApplication:(ACAppStoreApplication *)app inStore:(ACAppStore *)store;

@end
