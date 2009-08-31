//
//  ACAppStoreReviewsHeaderTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 21/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ACAppStoreApplicationDetails;


@interface ACAppStoreReviewsHeaderTableCell : UITableViewCell
{
	ACAppStoreApplicationDetails *appDetails;
	UILabel *appName;
	UILabel *appCompany;
	UILabel *versionLabel;
	UILabel *versionValue;
	UILabel *sizeLabel;
	UILabel *sizeValue;
	UILabel *dateLabel;
	UILabel *dateValue;
	UILabel *priceLabel;
	UILabel *priceValue;
}

@property (nonatomic, retain) ACAppStoreApplicationDetails *appDetails;
@property (nonatomic, retain) UILabel *appCompany;
@property (nonatomic, retain) UILabel *versionLabel;
@property (nonatomic, retain) UILabel *versionValue;
@property (nonatomic, retain) UILabel *sizeLabel;
@property (nonatomic, retain) UILabel *sizeValue;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *dateValue;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *priceValue;

@end
