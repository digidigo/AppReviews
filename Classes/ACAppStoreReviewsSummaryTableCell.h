//
//  ACAppStoreReviewsSummaryTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 22/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSRatingView;


@interface ACAppStoreReviewsSummaryTableCell : UITableViewCell
{
	UILabel *ratingsLabel;
	UILabel *ratingsValue;
	UILabel *reviewsLabel;
	UILabel *reviewsValue;
	PSRatingView *ratingsView;

	double averageRating;
	NSUInteger ratingsCount;
	NSUInteger reviewsCount;
}

@property (nonatomic, retain) UILabel *ratingsLabel;
@property (nonatomic, retain) UILabel *ratingsValue;
@property (nonatomic, retain) UILabel *reviewsLabel;
@property (nonatomic, retain) UILabel *reviewsValue;
@property (nonatomic, retain) PSRatingView *ratingsView;

@property (nonatomic, assign) double averageRating;
@property (nonatomic, assign) NSUInteger ratingsCount;
@property (nonatomic, assign) NSUInteger reviewsCount;

@end
