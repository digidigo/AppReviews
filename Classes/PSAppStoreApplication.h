//
//  PSAppStoreApplication.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


// Default to the US store as the apps "home store" (for looking up name, company, etc).
#define kDefaultStoreId	@"143441"


@interface PSAppStoreApplication : NSObject
{
	// Persistent members.
	NSString *name;
	NSString *company;
	NSString *appId;
	NSString *defaultStoreId;
	NSMutableDictionary *reviewsByStore;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *defaultStoreId;
@property (nonatomic, retain) NSMutableDictionary *reviewsByStore;

- (id)init;
- (id)initWithAppId:(NSString *)inAppId;
- (id)initWithName:(NSString *)inName appId:(NSString *)inAppId;
- (id)initWithName:(NSString *)inName company:(NSString *)inCompany appId:(NSString *)inAppId defaultStoreId:(NSString *)inStoreId;
- (void)resetReviews;

@end
