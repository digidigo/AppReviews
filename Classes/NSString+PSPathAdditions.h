//
//  NSString+PSPathAdditions.h
//  PSCommon
//
//  Created by Charles Gamble on 06/02/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Category on NSString for returning system, user paths.
 */
@interface NSString (PSPathAdditions)

/**
 * Gets the path to the ~/Documents folder.
 */
+ (NSString *)documentsPath;

/**
 * Gets the path to the ~/Library folder.
 */
+ (NSString *)libraryPath;

/**
 * Gets the path to the ~/Library/Caches folder.
 */
+ (NSString *)cachesPath;

/**
 * Gets the path to the tmp folder.
 */
+ (NSString *)tmpPath;

@end
