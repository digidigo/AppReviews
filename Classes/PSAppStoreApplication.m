//
//  PSAppStoreApplication.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "PSAppStoreReviews.h"
#import "AppCriticsAppDelegate.h"


@implementation PSAppStoreApplication

@synthesize name, company, appId, defaultStoreId, reviewsByStore;

- (id)init
{
	return [self initWithName:nil company:nil appId:nil defaultStoreId:kDefaultStoreId];
}

- (id)initWithAppId:(NSString *)inAppId
{
	return [self initWithName:nil company:nil appId:inAppId defaultStoreId:kDefaultStoreId];
}

- (id)initWithName:(NSString *)inName appId:(NSString *)inAppId
{
	return [self initWithName:inName company:nil appId:inAppId defaultStoreId:kDefaultStoreId];
}

// Designated initialiser.
- (id)initWithName:(NSString *)inName company:(NSString *)inCompany appId:(NSString *)inAppId defaultStoreId:(NSString *)inStoreId
{
	if (self = [super init])
	{
		self.name = inName;
		self.company = inCompany;
		self.appId = inAppId;
		self.defaultStoreId = inStoreId;
		self.reviewsByStore = [NSMutableDictionary dictionary];
		
		[self resetReviews];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	// Parent class NSObject does not implement initWithCoder:
	if (self = [super init])
	{
		// Initialise persistent members.
		self.name = [coder decodeObjectForKey:@"name"];
		self.company = [coder decodeObjectForKey:@"company"];
		self.appId = [coder decodeObjectForKey:@"appId"];
		self.defaultStoreId = [coder decodeObjectForKey:@"defaultStoreId"];
		self.reviewsByStore = [coder decodeObjectForKey:@"reviewsByStore"];
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// Parent class NSObject does not implement encodeWithCoder:
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.company forKey:@"company"];
	[encoder encodeObject:self.appId forKey:@"appId"];
	[encoder encodeObject:self.defaultStoreId forKey:@"defaultStoreId"];
	[encoder encodeObject:self.reviewsByStore forKey:@"reviewsByStore"];
}

- (void)dealloc
{
	[name release];
	[company release];
	[appId release];
	[defaultStoreId release];
	[reviewsByStore release];
	[super dealloc];
}

- (void)resetReviews
{
	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	//NSAssert(appId, @"Require appId to be set");
	NSAssert(reviewsByStore, @"Require reviewsByStore to be set");

	// Clear the store reviews dictionary.
	[reviewsByStore removeAllObjects];
	// Re-populate with all stores.
	for (PSAppStore *appStore in appDelegate.appStores)
	{
		PSAppStoreReviews *appStoreReviews = [[PSAppStoreReviews alloc] initWithAppId:self.appId storeId:appStore.storeId];
		[self.reviewsByStore setObject:appStoreReviews forKey:appStore.storeId];
		[appStoreReviews release];
	}
}

- (NSComparisonResult)compare:(PSAppStoreApplication *)other
{
	return [self.name compare:other.name];
}

@end
