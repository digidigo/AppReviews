//
//  ACAppStoreApplicationsViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ACEditAppStoreApplicationViewController;
@class ACAppStoreCountriesViewController;


@interface ACAppStoreApplicationsViewController : UITableViewController
{
	ACEditAppStoreApplicationViewController *editAppStoreApplicationViewController;
	ACAppStoreCountriesViewController *appStoreCountriesViewController;
	NSNumber *savedEditingState;
}

@property (nonatomic, retain) ACEditAppStoreApplicationViewController *editAppStoreApplicationViewController;
@property (nonatomic, retain) ACAppStoreCountriesViewController *appStoreCountriesViewController;

@end
