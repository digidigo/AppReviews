//
//  PSAppStoreReviewsHeaderTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 21/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSAppStoreApplicationDetails;
@class PSRatingView;


@interface PSAppStoreReviewsHeaderTableCell : UITableViewCell
{
	PSAppStoreApplicationDetails *appDetails;
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
	UILabel *currentTitle;
	UILabel *currentVersionLabel;
	UILabel *currentRatingsLabel;
	UILabel *currentRatingsValue;
	UILabel *currentReviewsLabel;
	UILabel *currentReviewsValue;
	PSRatingView *currentRatingsView;
	UILabel *allTitle;
	UILabel *allVersionsLabel;
	UILabel *allRatingsLabel;
	UILabel *allRatingsValue;
	UILabel *allReviewsLabel;
	UILabel *allReviewsValue;
	PSRatingView *allRatingsView;
}

@property (nonatomic, retain) PSAppStoreApplicationDetails *appDetails;
@property (nonatomic, retain) UILabel *appCompany;
@property (nonatomic, retain) UILabel *versionLabel;
@property (nonatomic, retain) UILabel *versionValue;
@property (nonatomic, retain) UILabel *sizeLabel;
@property (nonatomic, retain) UILabel *sizeValue;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *dateValue;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *priceValue;
@property (nonatomic, retain) UILabel *currentTitle;
@property (nonatomic, retain) UILabel *currentVersionLabel;
@property (nonatomic, retain) UILabel *currentRatingsLabel;
@property (nonatomic, retain) UILabel *currentRatingsValue;
@property (nonatomic, retain) UILabel *currentReviewsLabel;
@property (nonatomic, retain) UILabel *currentReviewsValue;
@property (nonatomic, retain) PSRatingView *currentRatingsView;
@property (nonatomic, retain) UILabel *allTitle;
@property (nonatomic, retain) UILabel *allVersionsLabel;
@property (nonatomic, retain) UILabel *allRatingsLabel;
@property (nonatomic, retain) UILabel *allRatingsValue;
@property (nonatomic, retain) UILabel *allReviewsLabel;
@property (nonatomic, retain) UILabel *allReviewsValue;
@property (nonatomic, retain) PSRatingView *allRatingsView;

@end
