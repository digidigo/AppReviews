//
//  NSDate+PSNSDateAdditions.h
//  AppCritics
//
//  Created by Charles Gamble on 02/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (PSNSDateAdditions)

+ (NSString *)ordinalForDay:(NSUInteger)day;
- (NSString *)friendlyDateStringWithFormat:(NSString *)format allowingWords:(BOOL)words;
- (NSString *)friendlyShortDateStringAllowingWords:(BOOL)words;
- (NSString *)friendlyMediumDateStringAllowingWords:(BOOL)words;
- (NSString *)friendlyLongDateStringAllowingWords:(BOOL)words;

@end
