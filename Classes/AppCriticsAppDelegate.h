//
//  AppCriticsAppDelegate.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright Charles Gamble 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kPSAppStoreApplicationDetailsUpdatedNotification @"PSAppStoreApplicationDetailsUpdatedNotification"
#define kPSAppStoreApplicationReviewsUpdatedNotification @"PSAppStoreApplicationReviewsUpdatedNotification"


@class PSAppReviewsStore;


@interface AppCriticsAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigationController;
	BOOL exiting;
	NSUserDefaults *settings;
	PSAppReviewsStore *appReviewsStore;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (assign) BOOL exiting;
@property (nonatomic, retain) NSUserDefaults *settings;

@end

