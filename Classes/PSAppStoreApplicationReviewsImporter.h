//
//  PSAppStoreApplicationReviewsImporter.h
//  AppCritics
//
//  Created by Charles Gamble on 09/04/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSAppReviewsStore.h"
#import "AppCriticsAppDelegate.h"


//@class PSAppStoreApplication;
//@class PSAppStore;


typedef enum
{
	ReviewsImportStateEmpty,
	ReviewsImportStateDownloading,
	ReviewsImportStateDownloadFailed,
	ReviewsImportStateParsing,
	ReviewsImportStateParseFailed,
	ReviewsImportStateComplete
} ReviewsImportState;


typedef enum
{
	ReviewsSeekingSortByPopup,
	ReviewsSeekingSummary,
	ReviewsSeekingRating,
	ReviewsSeekingReportConcern,
	ReviewsSeekingBy,
	ReviewsSeekingReview,
	ReviewsSeekingHelpful,
	ReviewsSeekingYes,
	ReviewsSeekingYesNoSeparator,
	ReviewsSeekingNo,
	ReviewsReadingSortByPopup,
	ReviewsReadingSummary,
	ReviewsReadingReportConcern,
	ReviewsReadingBy,
	ReviewsReadingReviewer,
	ReviewsReadingReviewVersionDate,
	ReviewsReadingReview,
	ReviewsReadingHelpful,
	ReviewsReadingYes,
	ReviewsReadingYesNoSeparator,
	ReviewsReadingNo,
	ReviewsParsingComplete
} ReviewsXMLState;


@interface PSAppStoreApplicationReviewsImporter : NSObject
{
	NSString *appIdentifier;
	NSString *storeIdentifier;

	ReviewsImportState importState;

	// Members used during file download.
	BOOL downloadCancelled;
	long long downloadFileSize;
	NSMutableData *downloadFileContents;
	NSString *downloadErrorMessage;

	// Members used during XML parsing.
	ReviewsXMLState xmlState;
	NSMutableString *currentString;
	NSString *currentReviewSummary;
	double currentReviewRating;
	NSString *currentReviewer;
	NSString *currentReviewVersion;
	NSString *currentReviewDate;
	NSString *currentReviewDetail;
	NSUInteger currentReviewIndex;
	NSMutableArray *reviews;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, assign) ReviewsImportState importState;
@property (copy) NSString *downloadErrorMessage;

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier;
- (void)fetchReviews;
- (NSArray *)reviews;

@end
