//
//  PSAppStoreReviewTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSRatingView;
@class PSAppStoreReview;


@interface PSAppStoreReviewTableCell : UITableViewCell
{
	UILabel *summaryLabel;
	UILabel *authorLabel;
	UILabel *detailLabel;
	PSRatingView *ratingView;
	PSAppStoreReview *review;
}

@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *detailLabel;
@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) PSAppStoreReview *review;

+ (CGFloat)tableView:(UITableView *)tableView heightForCellWithReview:(PSAppStoreReview *)inReview;

@end
