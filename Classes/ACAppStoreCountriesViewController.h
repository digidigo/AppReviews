//
//  ACAppStoreCountriesViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACAppStoreApplication;
@class ACAppStoreApplicationDetailsImporter;
@class ACAppStoreApplicationReviewsImporter;
@class ACAppStoreReviewsViewController;

@interface ACAppStoreCountriesViewController : UITableViewController <UIActionSheetDelegate>
{
	ACAppStoreApplication *appStoreApplication;
	UIBarButtonItem *updateButton;
	UILabel *remainingLabel;
	UIActivityIndicatorView *remainingSpinner;
	NSMutableArray *enabledStores;
	NSMutableArray *displayedStores;
	ACAppStoreReviewsViewController *appStoreReviewsViewController;

	// Members used when updating reviews.
	ACAppStoreApplicationDetailsImporter *detailsImporter;
	ACAppStoreApplicationReviewsImporter *reviewsImporter;
	NSMutableArray *storeIdsProcessed;
	NSMutableArray *storeIdsRemaining;
	NSMutableArray *unavailableStoreNames;
	NSMutableArray *failedStoreNames;
}

@property (nonatomic, retain) ACAppStoreApplication *appStoreApplication;

@end
