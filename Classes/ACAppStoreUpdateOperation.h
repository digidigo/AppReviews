//
//  ACAppStoreUpdateOperation.h
//  AppCritics
//
//  Created by Charles Gamble on 19/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ACAppStoreApplicationDetailsImporter;
@class ACAppStoreApplicationReviewsImporter;
@class ACAppStoreApplicationDetails;


@interface ACAppStoreUpdateOperation : NSOperation
{
	BOOL fetchReviews;
	ACAppStoreApplicationDetails *appDetails;
	ACAppStoreApplicationDetailsImporter *detailsImporter;
	ACAppStoreApplicationReviewsImporter *reviewsImporter;
}

@property (nonatomic, assign) BOOL fetchReviews;
@property (nonatomic, readonly) ACAppStoreApplicationDetails *appDetails;
@property (nonatomic, readonly) ACAppStoreApplicationDetailsImporter *detailsImporter;
@property (nonatomic, readonly) ACAppStoreApplicationReviewsImporter *reviewsImporter;

- (id)initWithApplicationDetails:(ACAppStoreApplicationDetails *)details;

@end
