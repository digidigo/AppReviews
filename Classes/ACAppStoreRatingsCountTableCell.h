//
//  PSAppStoreRatingsCountTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSRatingView;
@class PSCountView;
@class PSHorizontalBarView;

@interface PSAppStoreRatingsCountTableCell : UITableViewCell
{
	PSRatingView *ratingView;
	PSCountView *countView;
	PSHorizontalBarView *barView;
}

@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) PSCountView *countView;
@property (nonatomic, retain) PSHorizontalBarView *barView;

@end
