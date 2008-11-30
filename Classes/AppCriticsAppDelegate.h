//
//  AppCriticsAppDelegate.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright Charles Gamble 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


#define PSAppStoreReviewsUpdatedNotification @"PSAppStoreReviewsUpdatedNotification"


@class PSAppStore;
@class PSAppStoreApplication;


@interface AppCriticsAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigationController;
	BOOL exiting;
	NSUserDefaults *settings;
	NSString *documentsPath;
	NSArray *appStores;
	NSMutableArray *appStoreApplications;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (assign) BOOL exiting;
@property (nonatomic, retain) NSUserDefaults *settings;
@property (nonatomic, copy) NSString *documentsPath;
@property (retain) NSArray *appStores;
@property (retain) NSMutableArray *appStoreApplications;

- (PSAppStore *)storeForId:(NSString *)storeId;
- (PSAppStoreApplication *)applicationForId:(NSString *)appId;
- (void)saveData;

@end

