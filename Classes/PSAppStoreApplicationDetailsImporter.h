//
//  PSAppStoreApplicationDetailsImporter.h
//  AppCritics
//
//  Created by Charles Gamble on 16/03/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSProgressHandler.h"
#import "PSAppReviewsStore.h"
#import "AppCriticsAppDelegate.h"


@class PSAppStoreApplication;
@class PSAppStoreApplicationDetails;
@class PSAppStore;


typedef enum
{
	DetailsImportStateEmpty,
	DetailsImportStateDownloading,
	DetailsImportStateDownloadFailed,
	DetailsImportStateParsing,
	DetailsImportStateParseFailed,
	DetailsImportStateComplete
} DetailsImportState;


typedef enum
{
	DetailsSeekingAppGenre,
	DetailsSeekingCategory,
	DetailsSeekingReleased,
	DetailsSeekingCopyright,
	DetailsSeekingVersion,
	DetailsSeekingSize,
	DetailsSeekingPrice,
	DetailsSeekingCustomerRatings,
	DetailsSeekingCurrentRatingsNotEnoughReceivedDuplicate,
	DetailsSeekingCurrentRatingsDisclosure,
	DetailsSeekingCurrentRatingsTitle,
	DetailsSeekingCurrentAverageRating,
	DetailsSeekingCurrentRatingsCount,
	DetailsSeekingCurrentRatingsFiveStarsCount,
	DetailsSeekingCurrentRatingsFourStarsCount,
	DetailsSeekingCurrentRatingsThreeStarsCount,
	DetailsSeekingCurrentRatingsTwoStarsCount,
	DetailsSeekingCurrentRatingsOneStarCount,
	DetailsSeekingAllRatingsNotEnoughReceivedDuplicate,
	DetailsSeekingAllRatingsDisclosure,
	DetailsSeekingAllRatingsTitle,
	DetailsSeekingAllAverageRating,
	DetailsSeekingAllRatingsCount,
	DetailsSeekingAllRatingsFiveStarsCount,
	DetailsSeekingAllRatingsFourStarsCount,
	DetailsSeekingAllRatingsThreeStarsCount,
	DetailsSeekingAllRatingsTwoStarsCount,
	DetailsSeekingAllRatingsOneStarCount,
	DetailsSeekingRateThisSoftware,
	DetailsSeekingCustomerReviews,
	DetailsSeekingCurrentReviewsCountURL,
	DetailsSeekingCurrentReviewsCount,
	DetailsSeekingAllReviewsCountURL,
	DetailsSeekingAllReviewsCount,
	DetailsSeekingWriteReview,
	DetailsSeekingCompanyURL,
	DetailsSeekingCompanyURLDuplicate,
	DetailsSeekingSupportURL,
	DetailsReadingAppGenre,
	DetailsReadingCategory,
	DetailsReadingReleased,
	DetailsReadingCopyright,
	DetailsReadingVersion,
	DetailsReadingSize,
	DetailsReadingPrice,
	DetailsReadingCustomerRatings,
	DetailsReadingCurrentRatingsNotEnoughReceived,
	DetailsReadingCurrentRatingsNotEnoughReceivedDuplicate,
	DetailsReadingCurrentRatingsTitle,
	DetailsReadingCurrentRatingsCount,
	DetailsReadingCurrentRatingsFiveStarsCount,
	DetailsReadingCurrentRatingsFourStarsCount,
	DetailsReadingCurrentRatingsThreeStarsCount,
	DetailsReadingCurrentRatingsTwoStarsCount,
	DetailsReadingCurrentRatingsOneStarCount,
	DetailsReadingAllRatingsNotEnoughReceived,
	DetailsReadingAllRatingsNotEnoughReceivedDuplicate,
	DetailsReadingAllRatingsTitle,
	DetailsReadingAllRatingsCount,
	DetailsReadingAllRatingsFiveStarsCount,
	DetailsReadingAllRatingsFourStarsCount,
	DetailsReadingAllRatingsThreeStarsCount,
	DetailsReadingAllRatingsTwoStarsCount,
	DetailsReadingAllRatingsOneStarCount,
	DetailsReadingRateThisSoftware,
	DetailsReadingCustomerReviews,
	DetailsReadingCurrentReviewsCount,
	DetailsReadingAllReviewsCount,
	DetailsReadingWriteReview,
	DetailsParsingComplete
} DetailsXMLState;


@interface PSAppStoreApplicationDetailsImporter : NSObject
{
	NSString *appIdentifier;
	NSString *storeIdentifier;
	NSString *category;
	NSString *categoryIdentifier;
	NSUInteger ratingCountAll;
	NSUInteger ratingCountAll5Stars;
	NSUInteger ratingCountAll4Stars;
	NSUInteger ratingCountAll3Stars;
	NSUInteger ratingCountAll2Stars;
	NSUInteger ratingCountAll1Star;
	NSUInteger ratingCountCurrent;
	NSUInteger ratingCountCurrent5Stars;
	NSUInteger ratingCountCurrent4Stars;
	NSUInteger ratingCountCurrent3Stars;
	NSUInteger ratingCountCurrent2Stars;
	NSUInteger ratingCountCurrent1Star;
	double ratingAll;
	double ratingCurrent;
	NSUInteger reviewCountAll;
	NSUInteger reviewCountCurrent;
	PSReviewsSortOrder lastSortOrder;
	NSDate *lastUpdated;
	NSString *released;
	NSString *appVersion;
	NSString *appSize;
	NSString *localPrice;
	NSString *appName;
	NSString *appCompany;
	NSString *companyURL;
	NSString *companyURLTitle;
	NSString *supportURL;
	NSString *supportURLTitle;

	BOOL hasNewReviews;
	DetailsImportState importState;

	// Members used during file download.
	BOOL downloadCancelled;
	id<PSProgressHandler> downloadProgressHandler;
	long long downloadFileSize;
	NSMutableData *downloadFileContents;
	NSString *downloadErrorMessage;

	// Members used during XML parsing.
	DetailsXMLState xmlState;
	BOOL skippingCollapsedDisclosure;
	BOOL multipleVersions;
	NSMutableString *currentString;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *categoryIdentifier;
@property (nonatomic, assign) NSUInteger ratingCountAll;
@property (nonatomic, assign) NSUInteger ratingCountAll5Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll4Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll3Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll2Stars;
@property (nonatomic, assign) NSUInteger ratingCountAll1Star;
@property (nonatomic, assign) NSUInteger ratingCountCurrent;
@property (nonatomic, assign) NSUInteger ratingCountCurrent5Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent4Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent3Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent2Stars;
@property (nonatomic, assign) NSUInteger ratingCountCurrent1Star;
@property (nonatomic, assign) double ratingAll;
@property (nonatomic, assign) double ratingCurrent;
@property (nonatomic, assign) NSUInteger reviewCountAll;
@property (nonatomic, assign) NSUInteger reviewCountCurrent;
@property (nonatomic, assign) PSReviewsSortOrder lastSortOrder;
@property (nonatomic, copy) NSDate *lastUpdated;
@property (nonatomic, copy) NSString *released;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appSize;
@property (nonatomic, copy) NSString *localPrice;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appCompany;
@property (nonatomic, copy) NSString *companyURL;
@property (nonatomic, copy) NSString *companyURLTitle;
@property (nonatomic, copy) NSString *supportURL;
@property (nonatomic, copy) NSString *supportURLTitle;
@property (nonatomic, assign) BOOL hasNewReviews;
@property (nonatomic, assign) DetailsImportState importState;

@property (retain) id<PSProgressHandler> downloadProgressHandler;
@property (copy) NSString *downloadErrorMessage;

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier;
- (void)fetchDetails:(id <PSProgressHandler>)progressHandler;
- (void)copyDetailsTo:(PSAppStoreApplicationDetails *)receiver;

@end
