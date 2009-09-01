//
//	Copyright (c) 2008-2009, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppReviews nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDate+ARNSDateAdditions.h"


@implementation NSDate (ARNSDateAdditions)

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
