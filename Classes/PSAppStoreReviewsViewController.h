//
//  PSAppStoreReviewsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSAppStoreReviews;


@interface PSAppStoreReviewsViewController : UITableViewController
{
	PSAppStoreReviews *appStoreReviews;
	NSArray *userReviews;
}

@property (nonatomic, retain) PSAppStoreReviews *appStoreReviews;
@property (nonatomic, retain) NSArray *userReviews;

@end
