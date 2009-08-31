//
//  ACAppStoreReviewTableCell.h
//  AppCritics
//
//  Created by Charles Gamble on 20/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSRatingView;
@class ACAppStoreApplicationReview;


@interface ACAppStoreReviewTableCell : UITableViewCell
{
	UILabel *summaryLabel;
	UILabel *authorLabel;
	UITextView *detailLabel;
	PSRatingView *ratingView;
	ACAppStoreApplicationReview *review;
}

@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UITextView *detailLabel;
@property (nonatomic, retain) PSRatingView *ratingView;
@property (nonatomic, retain) ACAppStoreApplicationReview *review;

+ (CGFloat)tableView:(UITableView *)tableView heightForCellWithReview:(ACAppStoreApplicationReview *)inReview;

@end
