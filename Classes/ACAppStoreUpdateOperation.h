//
//  PSAppStoreUpdateOperation.h
//  AppCritics
//
//  Created by Charles Gamble on 19/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PSAppStoreApplicationDetailsImporter;
@class PSAppStoreApplicationReviewsImporter;
@class PSAppStoreApplicationDetails;


@interface PSAppStoreUpdateOperation : NSOperation
{
	BOOL fetchReviews;
	PSAppStoreApplicationDetails *appDetails;
	PSAppStoreApplicationDetailsImporter *detailsImporter;
	PSAppStoreApplicationReviewsImporter *reviewsImporter;
}

@property (nonatomic, assign) BOOL fetchReviews;
@property (nonatomic, readonly) PSAppStoreApplicationDetails *appDetails;
@property (nonatomic, readonly) PSAppStoreApplicationDetailsImporter *detailsImporter;
@property (nonatomic, readonly) PSAppStoreApplicationReviewsImporter *reviewsImporter;

- (id)initWithApplicationDetails:(PSAppStoreApplicationDetails *)details;

@end
