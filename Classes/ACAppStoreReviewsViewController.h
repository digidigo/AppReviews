//
//  ACAppStoreReviewsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ACAppStoreApplicationDetails;
@class ACAppStoreDetailsViewController;


@interface ACAppStoreReviewsViewController : UITableViewController
{
	UIBarButtonItem *updateButtonItem;
	UIBarButtonItem *activitySpinnerItem;
	UIActivityIndicatorView *activitySpinner;
	ACAppStoreApplicationDetails *appStoreDetails;
	ACAppStoreDetailsViewController *appStoreDetailsViewController;
	NSArray *userReviews;
}

@property (nonatomic, retain) UIBarButtonItem *updateButtonItem;
@property (nonatomic, retain) UIBarButtonItem *activitySpinnerItem;
@property (nonatomic, retain) UIActivityIndicatorView *activitySpinner;
@property (nonatomic, retain) ACAppStoreApplicationDetails *appStoreDetails;
@property (nonatomic, retain) NSArray *userReviews;

@end
