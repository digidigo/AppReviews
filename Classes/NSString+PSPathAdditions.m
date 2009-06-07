//
//  NSString+PSPathAdditions.m
//  PSCommon
//
//  Created by Charles Gamble on 06/02/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "NSString+PSPathAdditions.h"


/**
 * Category on NSString for returning system, user paths.
 */
@implementation NSString (PSPathAdditions)

/**
 * Gets the path to the ~/Documents folder.
 */
+ (NSString *)documentsPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

/**
 * Gets the path to the ~/Library folder.
 */
+ (NSString *)libraryPath
{
	NSString *homePath = NSHomeDirectory();
	return [homePath stringByAppendingPathComponent:@"Library"];
}

/**
 * Gets the path to the ~/Library/Caches folder.
 */
+ (NSString *)cachesPath
{
	return [[NSString libraryPath] stringByAppendingPathComponent:@"Caches"];
}

/**
 * Gets the path to the tmp folder.
 */
+ (NSString *)tmpPath
{
	return NSTemporaryDirectory();
}

@end
