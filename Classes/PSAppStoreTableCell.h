//
//  PSAppStoreTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 16/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSImageView;
@class PSRatingView;
@class PSCountView;

@interface PSAppStoreTableCell : UITableViewCell
{
	UILabel *nameLabel;
	PSImageView *flagView;
	PSRatingView *ratingView;
	PSCountView *countView;
}

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) PSImageView *flagView;
@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) PSCountView *countView;

@end
