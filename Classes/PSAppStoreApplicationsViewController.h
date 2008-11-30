//
//  PSAppStoreApplicationsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSEditAppStoreApplicationViewController;
@class PSAppStoreCountriesViewController;


@interface PSAppStoreApplicationsViewController : UITableViewController
{
	PSEditAppStoreApplicationViewController *editAppStoreApplicationViewController;
	PSAppStoreCountriesViewController *appStoreCountriesViewController;
}

@property (nonatomic, retain) PSEditAppStoreApplicationViewController *editAppStoreApplicationViewController;
@property (nonatomic, retain) PSAppStoreCountriesViewController *appStoreCountriesViewController;

@end
