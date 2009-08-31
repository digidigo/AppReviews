//
//  ACAppStoreDetailsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ACAppStoreApplicationDetails;


@interface ACAppStoreDetailsViewController : UITableViewController
{
	ACAppStoreApplicationDetails *appStoreDetails;
	BOOL useCurrentVersion;
}

@property (nonatomic, retain) ACAppStoreApplicationDetails *appStoreDetails;
@property (nonatomic, assign) BOOL useCurrentVersion;

@end
