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

#import "ARAppStoreApplicationReviewsImporter.h"
#import "ARAppStoreApplicationReview.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "PSLog.h"


@implementation ARAppStoreApplicationReviewsImporter

@synthesize appIdentifier, storeIdentifier, importState;

- (id)init
{
	return [self initWithAppIdentifier:nil storeIdentifier:nil];
}

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.appIdentifier = inAppIdentifier;
		self.storeIdentifier = inStoreIdentifier;
		self.importState = ReviewsImportStateEmpty;
		currentString = [[NSMutableString alloc] init];
		currentReviewSummary = nil;
		currentReviewRating = 0.0;
		currentReviewer = nil;
		currentReviewVersion = nil;
		currentReviewDate = nil;
		currentReviewDetail = nil;
		currentReviewIndex = 0;
		reviews = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[appIdentifier release];
	[storeIdentifier release];
	[currentString release];
	[currentReviewSummary release];
	[currentReviewer release];
	[currentReviewVersion release];
	[currentReviewDate release];
	[currentReviewDetail release];
	[reviews release];
	[super dealloc];
}

- (NSURL *)reviewsURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=%d&type=Purple+Software&onlyLatestVersion=false", self.appIdentifier, [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"]]];
}

- (NSString *)localXMLFilename
{
	NSString *documentsDirectory = [NSString documentsPath];
	NSString *result = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@-reviews.xml", self.appIdentifier, self.storeIdentifier]];
	return result;
}

- (NSArray *)reviews
{
	return [NSArray arrayWithArray:reviews];
}

- (void)processReviews:(NSData *)data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PSLogDebug(@"-->");

#ifdef DEBUG
	// Save XML file for debugging.
	[data writeToFile:[self localXMLFilename] atomically:YES];
#endif

	// Initialise some members used whilst parsing XML content.
	self.importState = ReviewsImportStateParsing;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
	xmlParser.delegate = self;
	xmlParser.shouldResolveExternalEntities = NO;
	xmlState = ReviewsSeekingSortByPopup;
	[currentString setString:@""];
	currentReviewSummary = nil;
	currentReviewRating = 0.0;
	currentReviewer = nil;
	currentReviewVersion = nil;
	currentReviewDate = nil;
	currentReviewDetail = nil;
	currentReviewIndex = 0;
	[reviews removeAllObjects];

	// Parse XML content.
	if (([xmlParser parse] == YES) && (xmlState == ReviewsParsingComplete))
	{
		PSLog(@"Successfully parsed XML document");
		self.importState = ReviewsImportStateComplete;
	}
	else
	{
		PSLog(@"Failed to parse XML document");
		self.importState = ReviewsImportStateParseFailed;
	}

	[xmlParser release];

	PSLogDebug(@"<--");
	[pool release];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSString *elementNameLower = [elementName lowercaseString];
	if ([elementNameLower isEqualToString:@"b"] || [elementNameLower isEqualToString:@"setfontstyle"])
	{
		[currentString setString:@""];
		switch (xmlState)
		{
			case ReviewsSeekingSummary:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingSummary;
				}
				break;
			case ReviewsSeekingReportConcern:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingReportConcern;
				}
				break;
			case ReviewsSeekingBy:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingBy;
				}
				break;
			case ReviewsSeekingReview:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingReview;
				}
				break;
			case ReviewsSeekingHelpful:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingHelpful;
				}
				break;
			case ReviewsSeekingYes:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingYes;
				}
				break;
			case ReviewsSeekingYesNoSeparator:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingYesNoSeparator;
				}
				break;
			case ReviewsSeekingNo:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = ReviewsReadingNo;
				}
				break;
		}
	}
	else if ([elementNameLower isEqualToString:@"hboxview"])
	{
		switch (xmlState)
		{
			case ReviewsSeekingRating:
			{
				NSString *rating = [attributeDict objectForKey:@"alt"];
				if (rating)
				{
					GTMRegex *ratingRegex = [GTMRegex regexWithPattern:@"^([0-9])( and a half)? star[s]?"];
					NSArray *subPatterns = [ratingRegex subPatternsOfString:rating];
					if (subPatterns)
					{
						float ratingFloat = (float)[[subPatterns objectAtIndex:1] integerValue];
						if ([subPatterns objectAtIndex:2] != [NSNull null])
						{
							ratingFloat += 0.5;
						}
						currentReviewRating = ratingFloat;
					}
					else
					{
						// Didn't match regex.
						currentReviewRating = 0.0;
					}
					xmlState = ReviewsSeekingReportConcern;
				}
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"popupbuttonview"])
	{
		switch (xmlState)
		{
			case ReviewsSeekingSortByPopup:
			{
				NSString *action = [attributeDict valueForKey:@"action"];
				if (action && [action isEqualToString:@"SortBy"])
					xmlState = ReviewsReadingSortByPopup;
				else
					xmlState = ReviewsSeekingSortByPopup;
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"gotourl"])
	{
		switch (xmlState)
		{
			case ReviewsReadingBy:
				[currentString setString:@""];
				xmlState = ReviewsReadingReviewer;
				break;
		}
	}
	else if ([elementNameLower isEqualToString:@"openurl"])
	{
		xmlState = ReviewsParsingComplete;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	switch (xmlState)
	{
		case ReviewsReadingSummary:
		case ReviewsReadingReportConcern:
		case ReviewsReadingBy:
		case ReviewsReadingReviewer:
		case ReviewsReadingReviewVersionDate:
		case ReviewsReadingReview:
		case ReviewsReadingHelpful:
		case ReviewsReadingYes:
		case ReviewsReadingYesNoSeparator:
		case ReviewsReadingNo:
			[currentString appendString:string];
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSString *elementNameLower = [elementName lowercaseString];
	if ([elementNameLower isEqualToString:@"b"] || [elementNameLower isEqualToString:@"setfontstyle"] || [elementNameLower isEqualToString:@"popupbuttonview"])
	{
		PSLogDebug(@"Read <%@> content: [%@]", elementNameLower, currentString);
		switch (xmlState)
		{
			case ReviewsReadingSortByPopup:
			{
				// We don't use this value.
				xmlState = ReviewsSeekingSummary;
				[currentString setString:@""];
				break;
			}
			case ReviewsReadingSummary:
			{
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^Page [0-9]+ of [0-9]+$"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]))
				{
					// Found a "Page 1 of 23" string instead of review summary.
					xmlState = ReviewsSeekingSummary;
				}
				else
				{
					// Found the review summary.
					currentReviewSummary = [currentString copy];
					xmlState = ReviewsSeekingRating;
				}
				[regex release];
				[currentString setString:@""];
				break;
			}
			case ReviewsReadingReportConcern:
			{
				// We don't use this value.
				xmlState = ReviewsSeekingBy;
				[currentString setString:@""];
				break;
			}
			case ReviewsReadingReviewVersionDate:
			{
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				// Example: - Version 1.1.0	- Aug 23, 2008
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^[ \t\n-]+[A-Za-z ]+([0-9.]+)[ \t\n-]+([^ \t\n-].*)$"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]) && ([substrings objectAtIndex:2] != [NSNull null]))
				{
					currentReviewVersion = [[substrings objectAtIndex:1] copy];
					currentReviewDate = [[substrings objectAtIndex:2] copy];
				}
				[regex release];
				[currentString setString:@""];
				xmlState = ReviewsSeekingReview;
				break;
			}
			case ReviewsReadingReview:
			{
				currentReviewDetail = [currentString copy];
				[currentString setString:@""];
				xmlState = ReviewsSeekingHelpful;
				break;
			}
			case ReviewsReadingHelpful:
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				// Skip over the "0 out of 15 customers found this review helpful"
				if ([currentString hasSuffix:@"?"])
					xmlState = ReviewsSeekingYes;
				else
					xmlState = ReviewsSeekingHelpful;
				[currentString setString:@""];
				break;
			case ReviewsReadingYes:
				[currentString setString:@""];
				xmlState = ReviewsSeekingYesNoSeparator;
				break;
			case ReviewsReadingYesNoSeparator:
				[currentString setString:@""];
				xmlState = ReviewsSeekingNo;
				break;
			case ReviewsReadingNo:
			{
				[currentString setString:@""];
				// Store current review info, ready for reading next review.
				currentReviewIndex++;
				ARAppStoreApplicationReview *thisReview = [[ARAppStoreApplicationReview alloc] initWithAppIdentifier:appIdentifier storeIdentifier:storeIdentifier];
				thisReview.summary = currentReviewSummary;
				thisReview.detail = currentReviewDetail;
				thisReview.reviewer = currentReviewer;
				thisReview.reviewDate = currentReviewDate;
				thisReview.rating = currentReviewRating;
				thisReview.appVersion = currentReviewVersion;
				thisReview.index = currentReviewIndex;
				[reviews addObject:thisReview];
				[thisReview release];
				// Reset temporary fields for next review.
				[currentReviewSummary release];
				currentReviewSummary = nil;
				[currentReviewDetail release];
				currentReviewDetail = nil;
				[currentReviewer release];
				currentReviewer = nil;
				[currentReviewDate release];
				currentReviewDate = nil;
				currentReviewRating = 0.0;
				[currentReviewVersion release];
				currentReviewVersion = nil;
				xmlState = ReviewsSeekingSummary;
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"gotourl"])
	{
		PSLogDebug(@"Read <%@> content: [%@]", elementNameLower, currentString);
		switch (xmlState)
		{
			case ReviewsReadingReviewer:
			{
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				currentReviewer = [currentString copy];
				[currentString setString:@""];
				xmlState = ReviewsReadingReviewVersionDate;
				break;
			}
		}
	}
}

@end
