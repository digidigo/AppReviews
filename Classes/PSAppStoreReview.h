//
//  PSAppStoreReview.h
//  AppCritics
//
//  Created by Charles Gamble on 23/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PSAppStoreReview : NSObject
{
	NSUInteger index;
	NSString *reviewer;
	float rating;
	NSString *summary;
	NSString *detail;
}

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *reviewer;
@property (nonatomic, assign) float rating;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *detail;

@end
