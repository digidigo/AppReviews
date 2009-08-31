//
//  ACAppStore.h
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ACAppStore : NSObject
{
	NSString *name;
	NSString *storeIdentifier;
	BOOL enabled;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, readonly) BOOL enabled;

- (id)initWithName:(NSString *)inName storeIdentifier:(NSString *)inStoreIdentifier;

@end
