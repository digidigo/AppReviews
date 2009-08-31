//
//  ACAppStoreRatingsCountTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSRatingView;
@class PSCountView;
@class ACHorizontalBarView;

@interface ACAppStoreRatingsCountTableCell : UITableViewCell
{
	PSRatingView *ratingView;
	PSCountView *countView;
	ACHorizontalBarView *barView;
}

@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) PSCountView *countView;
@property (nonatomic, retain) ACHorizontalBarView *barView;

@end
