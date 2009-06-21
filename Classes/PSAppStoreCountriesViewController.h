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

@interface PSAppStoreCountriesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
	PSAppStoreApplication *appStoreApplication;
	UITableView *tableView;
	UIToolbar *toolbar;
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
	NSMutableArray *unavailableStoreNames;
	NSMutableArray *failedStoreNames;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) PSAppStoreApplication *appStoreApplication;

@end
