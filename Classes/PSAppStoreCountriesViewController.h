//
//  PSAppStoreCountriesViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSAppStoreApplication;
@class PSProgressBarSheet;
@class PSAppStoreReviewsViewController;

@interface PSAppStoreCountriesViewController : UITableViewController
{
	PSAppStoreApplication *appStoreApplication;
	UIBarButtonItem *updateButton;
	NSMutableArray *enabledStores;
	NSMutableArray *displayedStores;
	PSAppStoreReviewsViewController *appStoreReviewsViewController;
	
	// Members used when updating reviews.
	PSProgressBarSheet *progressBarSheet;
	NSMutableArray *storeIdsProcessed;
	NSMutableArray *storeIdsRemaining;
}

@property (nonatomic, retain) PSAppStoreApplication *appStoreApplication;

@end
