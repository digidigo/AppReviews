//
//  PSAppStoreDetailsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSAppStoreApplicationDetails;


@interface PSAppStoreDetailsViewController : UITableViewController
{
	PSAppStoreApplicationDetails *appStoreDetails;
	BOOL useCurrentVersion;
}

@property (nonatomic, retain) PSAppStoreApplicationDetails *appStoreDetails;
@property (nonatomic, assign) BOOL useCurrentVersion;

@end
