//
//  PSAppStoreReviews.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSProgressHandler.h"
#import "AppCriticsAppDelegate.h"


@class PSAppStoreApplication;
@class PSAppStore;


typedef enum {
	SeekingCompany,
	SeekingAppName,
	SeekingCategory,
	SeekingReleased,
	SeekingCopyright,
	SeekingVersion,
	SeekingSize,
	SeekingPrice,
	SeekingWriteReview,
	SeekingAverageRatingLabel,
	SeekingAverageRatingValue,
	SeekingMostRecent,
	SeekingCustomerReviews,
	SeekingSortBy,
	SeekingMoreReviews,
	SeekingSummary,
	SeekingRating,
	SeekingNumFoundUseful,
	SeekingReviewer,
	SeekingReview,
	SeekingHelpful,
	SeekingYes,
	SeekingYesNoSeparator,
	SeekingNo,
	SeekingReportConcern,
	ReadingCompany,
	ReadingAppName,
	ReadingCategory,
	ReadingReleased,
	ReadingCopyright,
	ReadingVersion,
	ReadingSize,
	ReadingPrice,
	ReadingWriteReview,
	ReadingAverageRatingLabel,
	ReadingAverageRatingValue,
	ReadingMostRecent,
	ReadingCustomerReviews,
	ReadingSortBy,
	ReadingMoreReviews,
	ReadingSummary,
	ReadingRating,
	ReadingNumFoundUseful,
	ReadingReviewer,
	ReadingReview,
	ReadingHelpful,
	ReadingYes,
	ReadingYesNoSeparator,
	ReadingNo,
	ReadingReportConcern
} ReviewsXMLState;


@interface PSAppStoreReviews : NSObject
{
	// Persistent members.
	NSString *appId;
	NSString *storeId;
	NSString *released;
	NSString *appVersion;
	NSString *appSize;
	NSString *localPrice;
	NSUInteger countTotal;
	float averageRating;
	PSReviewsSortOrder lastSortOrder;
	NSDate *lastUpdated;
	
	// Non-persistent members.
	NSString *appName;
	NSString *appCompany;
	NSUInteger countFound;
	NSMutableArray *reviews;
	BOOL hasNewReviews;

	// Members used during file download.
	BOOL downloadCancelled;
	id<PSProgressHandler> downloadProgressHandler;
	long long downloadFileSize;
	NSMutableData *downloadFileContents;
	NSString *downloadErrorMessage;
	
	// Members used during XML parsing.
	ReviewsXMLState xmlState;
	NSUInteger countFirst;
	NSUInteger countLast;
	NSMutableString *currentString;
	NSString *currentReviewSummary;
	float currentReviewRating;
	NSString *currentReviewer;
	NSString *currentReviewDetail;
}

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, copy) NSString *released;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appSize;
@property (nonatomic, copy) NSString *localPrice;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appCompany;
@property (nonatomic, assign) NSUInteger countFound;
@property (nonatomic, assign) NSUInteger countFirst;
@property (nonatomic, assign) NSUInteger countLast;
@property (nonatomic, assign) NSUInteger countTotal;
@property (nonatomic, assign) float averageRating;
@property (nonatomic, assign) PSReviewsSortOrder lastSortOrder;
@property (nonatomic, copy) NSDate *lastUpdated;
@property (nonatomic, retain) NSMutableArray *reviews;
@property (nonatomic, assign) BOOL hasNewReviews;
@property (retain) id<PSProgressHandler> downloadProgressHandler;
@property (copy) NSString *downloadErrorMessage;

- (id)initWithAppId:(NSString *)inAppId storeId:(NSString *)inStoreId;
- (void)saveReviews;
- (void)loadReviews;
- (void)deleteReviews;
- (void)fetchReviews:(id <PSProgressHandler>)progressHandler;

@end
