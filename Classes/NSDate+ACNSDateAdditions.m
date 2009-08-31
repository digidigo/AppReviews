//
//  NSDate+PSNSDateAdditions.m
//  AppCritics
//
//  Created by Charles Gamble on 02/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "NSDate+PSNSDateAdditions.h"


@implementation NSDate (PSNSDateAdditions)

+ (NSString *)ordinalForDay:(NSUInteger)day
{
	NSString *result = @"";
	switch (day)
	{
		case 1:
		case 21:
		case 31:
			result = [NSString stringWithFormat:@"%dst", day];
			break;
		case 2:
		case 22:
			result = [NSString stringWithFormat:@"%dnd", day];
			break;
		case 3:
		case 23:
			result = [NSString stringWithFormat:@"%drd", day];
			break;
		default:
			result = [NSString stringWithFormat:@"%dth", day];
			break;
	}
	return result;
}

- (NSString *)friendlyShortDateStringAllowingWords:(BOOL)words
{
	// Get my day of month (for the ordinal).
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
	NSInteger dayOfMonth = dateComps.day;
	NSString *dateFmt = [NSString stringWithFormat:@"'%@' MMM yyyy", [NSDate ordinalForDay:dayOfMonth]];
	return [self friendlyDateStringWithFormat:dateFmt allowingWords:words];
}

- (NSString *)friendlyMediumDateStringAllowingWords:(BOOL)words
{
	// Get my day of month (for the ordinal).
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
	NSInteger dayOfMonth = dateComps.day;
	NSString *dateFmt = [NSString stringWithFormat:@"'%@' MMMM yyyy", [NSDate ordinalForDay:dayOfMonth]];
	return [self friendlyDateStringWithFormat:dateFmt allowingWords:words];
}

- (NSString *)friendlyLongDateStringAllowingWords:(BOOL)words
{
	// Get my day of month (for the ordinal).
	NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
	NSInteger dayOfMonth = dateComps.day;
	NSString *dateFmt = [NSString stringWithFormat:@"EEEE, '%@' MMMM yyyy", [NSDate ordinalForDay:dayOfMonth]];
	return [self friendlyDateStringWithFormat:dateFmt allowingWords:words];
}

- (NSString *)friendlyDateStringWithFormat:(NSString *)format allowingWords:(BOOL)words
{
	NSString *result = nil;

	NSCalendar *currCalendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

	// Get my date, ignoring time values.
	NSDateComponents *dateComps = [currCalendar components:unitFlags fromDate:self];
	NSDate *selfDate = [currCalendar dateFromComponents:dateComps];

	// Build friendly-word if required.
	if (words)
	{
		// Get today's date, ignoring time values.
		dateComps = [currCalendar components:unitFlags fromDate:[NSDate date]];
		NSDate *nowDate = [currCalendar dateFromComponents:dateComps];
		NSComparisonResult compareResult = [selfDate compare:nowDate];
		if (compareResult == NSOrderedSame)
		{
			// Dates are the same.
			result = @"Today";
		}
		else if (compareResult == NSOrderedAscending)
		{
			// Get yesterday's date, ignoring time values.
			NSDateComponents *offset = [[NSDateComponents alloc] init];
			offset.day = -1;
			NSDate *yesterdayDate = [currCalendar dateByAddingComponents:offset toDate:nowDate options:0];
			[offset release];
			if ([selfDate compare:yesterdayDate] == NSOrderedSame)
			{
				result = @"Yesterday";
			}
		}
		else if (compareResult == NSOrderedDescending)
		{
			// Get tomorrow's date, ignoring time values.
			NSDateComponents *offset = [[NSDateComponents alloc] init];
			offset.day = 1;
			NSDate *tomorrowDate = [currCalendar dateByAddingComponents:offset toDate:nowDate options:0];
			[offset release];
			if ([selfDate compare:tomorrowDate] == NSOrderedSame)
			{
				result = @"Tomorrow";
			}
		}
	}

	// Build a date string if not resolved to a common word yet.
	if (result == nil)
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setCalendar:[NSCalendar currentCalendar]];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateFormat:format];
		result = [dateFormatter stringFromDate:selfDate];
		[dateFormatter release];
	}

	return result;
}

@end
