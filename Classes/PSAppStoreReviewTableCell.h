//
//  PSAppStoreReviewTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSRatingView;
@class PSAppStoreApplicationReview;


@interface PSAppStoreReviewTableCell : UITableViewCell
{
	UILabel *summaryLabel;
	UILabel *authorLabel;
	UILabel *detailLabel;
	PSRatingView *ratingView;
	PSAppStoreApplicationReview *review;
}

@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *detailLabel;
@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) PSAppStoreApplicationReview *review;

+ (CGFloat)tableView:(UITableView *)tableView heightForCellWithReview:(PSAppStoreApplicationReview *)inReview;

@end
