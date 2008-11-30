//
//  PSAppStoreReview.m
//  AppCritics
//
//  Created by Charles Gamble on 23/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReview.h"


@implementation PSAppStoreReview

@synthesize index, reviewer, rating, summary, detail;

- (id)init
{
	if (self = [super init])
	{
		index = 0;
		reviewer = nil;
		rating = 0.0;
		summary = nil;
		detail = nil;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	// Parent class NSObject does not implement initWithCoder:
	if (self = [super init])
	{
		// Initialise persistent members.
		self.index = [coder decodeIntegerForKey:@"index"];
		self.reviewer = [coder decodeObjectForKey:@"reviewer"];
		self.rating = [coder decodeFloatForKey:@"rating"];
		self.summary = [coder decodeObjectForKey:@"summary"];
		self.detail = [coder decodeObjectForKey:@"detail"];
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// Parent class NSObject does not implement encodeWithCoder:
	[encoder encodeInteger:self.index forKey:@"index"];
	[encoder encodeObject:self.reviewer forKey:@"reviewer"];
	[encoder encodeFloat:self.rating forKey:@"rating"];
	[encoder encodeObject:self.summary forKey:@"summary"];
	[encoder encodeObject:self.detail forKey:@"detail"];
}

- (void)dealloc
{
	[reviewer release];
	[summary release];
	[detail release];
	[super dealloc];
}

@end
