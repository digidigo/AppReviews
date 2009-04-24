//
//  PSAppStore.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStore.h"


@implementation PSAppStore

@synthesize name, storeIdentifier, enabled;

- (id)init
{
	return [self initWithName:nil storeIdentifier:nil];
}

// Designated initialiser.
- (id)initWithName:(NSString *)inName storeIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.name = inName;
		self.storeIdentifier = inStoreIdentifier;
		enabled = NO;
		if (storeIdentifier && [storeIdentifier length] > 0)
		{
			// Set the enabled flag from the app preferences.
			enabled = [[NSUserDefaults standardUserDefaults] boolForKey:storeIdentifier];
		}
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[storeIdentifier release];
	[super dealloc];
}

- (NSComparisonResult)compare:(PSAppStore *)other
{
	return [self.name compare:other.name];
}

@end
