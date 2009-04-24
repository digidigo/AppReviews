//
//  PSAppStoreCountriesViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSAppStoreApplication;
@class PSAppStoreApplicationDetailsImporter;
@class PSAppStoreApplicationReviewsImporter;
@class PSProgressHUD;
@class PSAppStoreReviewsViewController;

@interface PSAppStoreCountriesViewController : UITableViewController
{
	PSAppStoreApplication *appStoreApplication;
	UIBarButtonItem *updateButton;
	NSMutableArray *enabledStores;
	NSMutableArray *displayedStores;
	PSAppStoreReviewsViewController *appStoreReviewsViewController;
	
	// Members used when updating reviews.
	PSAppStoreApplicationDetailsImporter *detailsImporter;
	PSAppStoreApplicationReviewsImporter *reviewsImporter;
	PSProgressHUD *progressHUD;
	NSMutableArray *storeIdsProcessed;
	NSMutableArray *storeIdsRemaining;
	NSMutableArray *failedStoreNames;
}

@property (nonatomic, retain) PSAppStoreApplication *appStoreApplication;

@end
