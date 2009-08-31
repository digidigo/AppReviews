//
//  AppCriticsAppDelegate.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright Charles Gamble 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kACAppStoreVerifyOperationDidStartNotification @"ACAppStoreVerifyOperationDidStartNotification"
#define kACAppStoreVerifyOperationDidFailNotification @"ACAppStoreVerifyOperationDidFailNotification"
#define kACAppStoreVerifyOperationDidFinishNotification @"ACAppStoreVerifyOperationDidFinishNotification"

#define kACAppStoreUpdateOperationDidStartNotification @"ACAppStoreUpdateOperationDidStartNotification"
#define kACAppStoreUpdateOperationDidFailNotification @"ACAppStoreUpdateOperationDidFailNotification"
#define kACAppStoreUpdateOperationDidFinishNotification @"ACAppStoreUpdateOperationDidFinishNotification"


@class ACAppReviewsStore;


@interface AppCriticsAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigationController;
	BOOL exiting;
	NSUserDefaults *settings;
	NSOperationQueue *operationQueue;
	NSUInteger networkUsageCount;
	ACAppReviewsStore *appReviewsStore;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (assign) BOOL exiting;
@property (nonatomic, retain) NSUserDefaults *settings;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

- (void)increaseNetworkUsageCount;
- (void)decreaseNetworkUsageCount;
- (void)makeOperationQueuesPerformSelector:(SEL)selector;
- (void)cancelAllOperations;
- (void)suspendAllOperations;
- (void)resumeAllOperations;

@end

