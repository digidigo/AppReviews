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
@class PSAppStoreReviewsViewController;

@interface PSAppStoreCountriesViewController : UITableViewController <UIActionSheetDelegate>
{
	PSAppStoreApplication *appStoreApplication;
	UIBarButtonItem *updateButton;
	UILabel *remainingLabel;
	UIActivityIndicatorView *remainingSpinner;
	NSMutableArray *enabledStores;
	NSMutableArray *displayedStores;
	PSAppStoreReviewsViewController *appStoreReviewsViewController;

	// Members used when updating reviews.
	PSAppStoreApplicationDetailsImporter *detailsImporter;
	PSAppStoreApplicationReviewsImporter *reviewsImporter;
	NSMutableArray *storeIdsProcessed;
	NSMutableArray *storeIdsRemaining;
	NSMutableArray *unavailableStoreNames;
	NSMutableArray *failedStoreNames;
}

@property (nonatomic, retain) PSAppStoreApplication *appStoreApplication;

@end
