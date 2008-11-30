//
//  PSAppStore.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PSAppStore : NSObject
{
	NSString *name;
	NSString *storeId;
	BOOL enabled;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, readonly) BOOL enabled;

- (id)initWithName:(NSString *)inName storeId:(NSString *)inStoreId;

@end
