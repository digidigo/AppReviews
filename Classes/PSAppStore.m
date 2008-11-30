//
//  PSAppStore.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStore.h"


@implementation PSAppStore

@synthesize name, storeId, enabled;

- (id)init
{
	return [self initWithName:nil storeId:nil];
}

// Designated initialiser.
- (id)initWithName:(NSString *)inName storeId:(NSString *)inStoreId
{
	if (self = [super init])
	{
		self.name = inName;
		self.storeId = inStoreId;
		enabled = NO;
		if (storeId && [storeId length] > 0)
		{
			// Set the enabled flag from the app preferences.
			enabled = [[NSUserDefaults standardUserDefaults] boolForKey:storeId];
		}
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[storeId release];
	[super dealloc];
}

- (NSComparisonResult)compare:(PSAppStore *)other
{
	return [self.name compare:other.name];
}

@end
