//
//  PSAppStoreApplicationDetailsImporter.m
//  AppCritics
//
//  Created by Charles Gamble on 16/03/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreApplicationDetailsImporter.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "AppCriticsAppDelegate.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "PSLog.h"


@implementation PSAppStoreApplicationDetailsImporter

@synthesize appIdentifier, storeIdentifier, category, categoryIdentifier, ratingCountAll, ratingCountCurrent, ratingAll, ratingCurrent, reviewCountAll, reviewCountCurrent, lastSortOrder, lastUpdated;
@synthesize released, appVersion, appSize, localPrice, appName, appCompany, companyURL, companyURLTitle, supportURL, supportURLTitle;
@synthesize ratingCountAll5Stars, ratingCountAll4Stars, ratingCountAll3Stars, ratingCountAll2Stars, ratingCountAll1Star;
@synthesize ratingCountCurrent5Stars, ratingCountCurrent4Stars, ratingCountCurrent3Stars, ratingCountCurrent2Stars, ratingCountCurrent1Star;
@synthesize hasNewReviews, importState;

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
		self.category = nil;
		self.categoryIdentifier = nil;
		self.ratingCountAll = 0;
		self.ratingCountAll5Stars = 0;
		self.ratingCountAll4Stars = 0;
		self.ratingCountAll3Stars = 0;
		self.ratingCountAll2Stars = 0;
		self.ratingCountAll1Star = 0;
		self.ratingCountCurrent = 0;
		self.ratingCountCurrent5Stars = 0;
		self.ratingCountCurrent4Stars = 0;
		self.ratingCountCurrent3Stars = 0;
		self.ratingCountCurrent2Stars = 0;
		self.ratingCountCurrent1Star = 0;
		self.ratingAll = 0.0;
		self.ratingCurrent = 0.0;
		self.reviewCountAll = 0;
		self.reviewCountCurrent = 0;
		self.released = nil;
		self.appVersion = nil;
		self.appSize = nil;
		self.localPrice = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.companyURL = nil;
		self.companyURLTitle = nil;
		self.supportURL = nil;
		self.supportURLTitle = nil;
		self.lastSortOrder = (PSReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		self.lastUpdated = [NSDate distantPast];
		self.hasNewReviews = NO;
		self.importState = DetailsImportStateEmpty;
		currentString = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[appIdentifier release];
	[storeIdentifier release];
	[category release];
	[categoryIdentifier release];
	[released release];
	[appVersion release];
	[appSize release];
	[localPrice release];
	[appName release];
	[appCompany release];
	[companyURL release];
	[companyURLTitle release];
	[supportURL release];
	[supportURLTitle release];
	[lastUpdated release];
	[currentString release];
	[super dealloc];
}

- (NSURL *)detailsURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", appIdentifier]];
}

- (NSString *)localXMLFilename
{
	NSString *documentsDirectory = [NSString documentsPath];
	NSString *result = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@-details.xml", self.appIdentifier, self.storeIdentifier]];
	return result;
}

- (void)processDetails:(NSData *)data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#ifdef DEBUG
	// Save XML file for debugging.
	[data writeToFile:[self localXMLFilename] atomically:YES];
#endif

	// Initialise some members used whilst parsing XML content.
	self.importState = DetailsImportStateParsing;
	skippingCollapsedDisclosure = NO;
	multipleVersions = YES;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
	xmlParser.delegate = self;
	xmlParser.shouldResolveExternalEntities = NO;
	xmlState = DetailsCheckingAvailability;
	[currentString setString:@""];

	// Parse XML content.
	if (([xmlParser parse] == YES) && (xmlState == DetailsParsingComplete))
	{
		PSLog(@"Successfully parsed XML document");
		self.lastUpdated = [NSDate date];
		self.lastSortOrder = (PSReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		self.importState = DetailsImportStateComplete;
	}
	else
	{
		PSLog(@"Failed to parse XML document");
		if (self.importState == DetailsImportStateParsing)
			self.importState = DetailsImportStateParseFailed;
	}

	[xmlParser release];

	[pool release];
}

- (void)copyDetailsTo:(PSAppStoreApplicationDetails *)receiver
{
	receiver.appIdentifier = self.appIdentifier;
	receiver.storeIdentifier = self.storeIdentifier;
	receiver.category = self.category;
	receiver.categoryIdentifier = self.categoryIdentifier;
	receiver.ratingCountAll = self.ratingCountAll;
	receiver.ratingCountAll5Stars = self.ratingCountAll5Stars;
	receiver.ratingCountAll4Stars = self.ratingCountAll4Stars;
	receiver.ratingCountAll3Stars = self.ratingCountAll3Stars;
	receiver.ratingCountAll2Stars = self.ratingCountAll2Stars;
	receiver.ratingCountAll1Star = self.ratingCountAll1Star;
	receiver.ratingCountCurrent = self.ratingCountCurrent;
	receiver.ratingCountCurrent5Stars = self.ratingCountCurrent5Stars;
	receiver.ratingCountCurrent4Stars = self.ratingCountCurrent4Stars;
	receiver.ratingCountCurrent3Stars = self.ratingCountCurrent3Stars;
	receiver.ratingCountCurrent2Stars = self.ratingCountCurrent2Stars;
	receiver.ratingCountCurrent1Star = self.ratingCountCurrent1Star;
	receiver.ratingAll = self.ratingAll;
	receiver.ratingCurrent = self.ratingCurrent;
	receiver.reviewCountAll = self.reviewCountAll;
	receiver.reviewCountCurrent = self.reviewCountCurrent;
	receiver.lastSortOrder = self.lastSortOrder;
	receiver.lastUpdated = self.lastUpdated;
	receiver.released = self.released;
	receiver.appVersion = self.appVersion;
	receiver.appSize = self.appSize;
	receiver.localPrice = self.localPrice;
	receiver.appName = self.appName;
	receiver.appCompany = self.appCompany;
	receiver.companyURL = self.companyURL;
	receiver.companyURLTitle = self.companyURLTitle;
	receiver.supportURL = self.supportURL;
	receiver.supportURLTitle = self.supportURLTitle;
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSString *elementNameLower = [elementName lowercaseString];
	if ([elementNameLower isEqualToString:@"document"])
	{
		switch (xmlState)
		{
			case DetailsCheckingAvailability:
			{
				id browsePath = [attributeDict valueForKey:@"browsePath"];
				if (browsePath != nil)
				{
					// App seems to be available, continue parsing file.
					xmlState = DetailsSeekingAppGenre;
				}
				else
				{
					// App seems to be unavailable, stop parsing file.
					self.importState = DetailsImportStateUnavailable;
					[parser abortParsing];
				}
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"b"] || [elementNameLower isEqualToString:@"setfontstyle"] || [elementNameLower isEqualToString:@"pathelement"])
	{
		[currentString setString:@""];
		switch (xmlState)
		{
			case DetailsSeekingAppGenre:
				if ([elementNameLower isEqualToString:@"pathelement"])
				{
					self.category = [attributeDict objectForKey:@"displayName"];
					xmlState = DetailsReadingAppGenre;
				}
				break;
			case DetailsSeekingCategory:
				if (appName && appCompany && [elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCategory;
				}
				break;
			case DetailsSeekingReleased:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingReleased;
				}
				break;
			case DetailsSeekingCopyright:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCopyright;
				}
				break;
			case DetailsSeekingVersion:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingVersion;
				}
				break;
			case DetailsSeekingSize:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingSize;
				}
				break;
			case DetailsSeekingPrice:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingPrice;
				}
				break;
			case DetailsSeekingCustomerRatings:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingCustomerRatings;
				}
				break;
			case DetailsSeekingCurrentRatingsDisclosure:
				if (!skippingCollapsedDisclosure && [elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsNotEnoughReceived;
				}
				break;
			case DetailsSeekingCurrentRatingsNotEnoughReceivedDuplicate:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsNotEnoughReceivedDuplicate;
					skippingCollapsedDisclosure = NO;
				}
				break;
			case DetailsSeekingCurrentRatingsTitle:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsTitle;
				}
				break;
			case DetailsSeekingCurrentRatingsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsCount;
				}
				break;
			case DetailsSeekingCurrentRatingsFiveStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsFiveStarsCount;
				}
				break;
			case DetailsSeekingCurrentRatingsFourStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsFourStarsCount;
				}
				break;
			case DetailsSeekingCurrentRatingsThreeStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsThreeStarsCount;
				}
				break;
			case DetailsSeekingCurrentRatingsTwoStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsTwoStarsCount;
				}
				break;
			case DetailsSeekingCurrentRatingsOneStarCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingCurrentRatingsOneStarCount;
				}
				break;
			case DetailsSeekingAllRatingsDisclosure:
				if (!skippingCollapsedDisclosure && [elementNameLower isEqualToString:@"setfontstyle"])
				{
					// Not enough ratings.
					xmlState = DetailsReadingAllRatingsNotEnoughReceived;
				}
				break;
			case DetailsSeekingAllRatingsNotEnoughReceivedDuplicate:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsNotEnoughReceivedDuplicate;
					skippingCollapsedDisclosure = NO;
				}
				break;
			case DetailsSeekingAllRatingsTitle:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsTitle;
				}
				break;
			case DetailsSeekingAllRatingsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsCount;
				}
				break;
			case DetailsSeekingAllRatingsFiveStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsFiveStarsCount;
				}
				break;
			case DetailsSeekingAllRatingsFourStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsFourStarsCount;
				}
				break;
			case DetailsSeekingAllRatingsThreeStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsThreeStarsCount;
				}
				break;
			case DetailsSeekingAllRatingsTwoStarsCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsTwoStarsCount;
				}
				break;
			case DetailsSeekingAllRatingsOneStarCount:
				if ([elementNameLower isEqualToString:@"setfontstyle"])
				{
					xmlState = DetailsReadingAllRatingsOneStarCount;
				}
				break;
			case DetailsSeekingRateThisSoftware:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingRateThisSoftware;
				}
				break;
			case DetailsSeekingCustomerReviews:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingCustomerReviews;
				}
				break;
			case DetailsSeekingCurrentReviewsCount:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingCurrentReviewsCount;
				}
				break;
			case DetailsSeekingAllReviewsCount:
				if ([elementNameLower isEqualToString:@"b"])
				{
					xmlState = DetailsReadingAllReviewsCount;
				}
				break;
			case DetailsSeekingWriteReview:
				xmlState = DetailsReadingWriteReview;
				break;
		}
	}
	else if ([elementNameLower isEqualToString:@"picturebuttonview"])
	{
		switch (xmlState)
		{
			case DetailsSeekingCurrentRatingsDisclosure:
			{
				NSString *disclosureState = [attributeDict objectForKey:@"alt"];
				if ([disclosureState isEqualToString:@"expanded"])
					xmlState = DetailsSeekingCurrentRatingsTitle;
				else
				{
					// We need to skip the "collapsed" disclosure.
					xmlState = DetailsSeekingCurrentRatingsDisclosure;
					skippingCollapsedDisclosure = YES;
				}
				break;
			}
			case DetailsSeekingAllRatingsDisclosure:
			{
				NSString *disclosureState = [attributeDict objectForKey:@"alt"];
				if ([disclosureState isEqualToString:@"expanded"])
					xmlState = DetailsSeekingAllRatingsTitle;
				else
				{
					// We need to skip the "collapsed" disclosure.
					xmlState = DetailsSeekingAllRatingsDisclosure;
					skippingCollapsedDisclosure = YES;
				}
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"hboxview"])
	{
		switch (xmlState)
		{
			case DetailsSeekingCurrentAverageRating:
			{
				NSString *rating = [attributeDict objectForKey:@"alt"];
				GTMRegex *ratingRegex = [GTMRegex regexWithPattern:@"^([0-9])( and a half)? star[s]?"];
				NSArray *subPatterns = [ratingRegex subPatternsOfString:rating];
				if (subPatterns)
				{
					float ratingFloat = (float)[[subPatterns objectAtIndex:1] integerValue];
					if ([subPatterns objectAtIndex:2] != [NSNull null])
					{
						ratingFloat += 0.5;
					}
					self.ratingCurrent = ratingFloat;
				}
				else
				{
					// Didn't match regex.
					self.ratingCurrent = 0.0;
				}
				xmlState = DetailsSeekingCurrentRatingsCount;
				break;
			}
			case DetailsSeekingAllAverageRating:
			{
				NSString *rating = [attributeDict objectForKey:@"alt"];
				GTMRegex *ratingRegex = [GTMRegex regexWithPattern:@"^([0-9])( and a half)? star[s]?"];
				NSArray *subPatterns = [ratingRegex subPatternsOfString:rating];
				if (subPatterns)
				{
					float ratingFloat = (float)[[subPatterns objectAtIndex:1] integerValue];
					if ([subPatterns objectAtIndex:2] != [NSNull null])
					{
						ratingFloat += 0.5;
					}
					self.ratingAll = ratingFloat;
				}
				else
				{
					// Didn't match regex.
					self.ratingAll = 0.0;
				}
				xmlState = DetailsSeekingAllRatingsCount;
				break;
			}
		}
	}
	else if ([elementNameLower isEqualToString:@"openurl"])
	{
		switch (xmlState)
		{
			case DetailsSeekingCurrentReviewsCountURL:
			case DetailsSeekingAllReviewsCountURL:
			case DetailsSeekingCompanyURL:
				self.companyURL = [attributeDict objectForKey:@"url"];
				self.companyURLTitle = [attributeDict objectForKey:@"draggingName"];
				xmlState = DetailsSeekingCompanyURLDuplicate;
				break;
			case DetailsSeekingCompanyURLDuplicate:
				xmlState = DetailsSeekingSupportURL;
				break;
			case DetailsSeekingSupportURL:
				self.supportURL = [attributeDict objectForKey:@"url"];
				self.supportURLTitle = [attributeDict objectForKey:@"draggingName"];
				xmlState = DetailsParsingComplete;
				break;
		}
	}
	else if ([elementNameLower isEqualToString:@"gotourl"])
	{
		switch (xmlState)
		{
			case DetailsSeekingCategory:
			{
				NSString *url = [attributeDict objectForKey:@"url"];
				NSString *value = [attributeDict objectForKey:@"draggingName"];
				if (value)
				{
					NSRange viewSoftwareQuery = [url rangeOfString:@"viewSoftware?"];
					NSRange viewArtistQuery = [url rangeOfString:@"viewArtist?"];
					if (viewArtistQuery.location != NSNotFound)
					{
						self.appCompany = value;
					}
					else if (viewSoftwareQuery.location != NSNotFound)
					{
						self.appName = value;
					}
				}
				break;
			}
			case DetailsSeekingCurrentReviewsCountURL:
			case DetailsSeekingAllReviewsCountURL:
			{
				NSString *url = [attributeDict objectForKey:@"url"];
				NSRange reviewsQuery = [url rangeOfString:@"viewContentsUserReviews?"];
				if (reviewsQuery.location != NSNotFound)
				{
					// URL is used for fetching reviews, now check if they are for current version or all versions.
					NSRange currentQuery = [url rangeOfString:@"onlyLatestVersion=true"];
					if (currentQuery.location != NSNotFound)
					{
						// URL is for current version reviews.
						xmlState = DetailsSeekingCurrentReviewsCount;
					}
					else
					{
						// URL is for all version reviews.
						xmlState = DetailsSeekingAllReviewsCount;
					}
				}
				break;
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	switch (xmlState)
	{
		case DetailsReadingAppGenre:
		case DetailsReadingCategory:
		case DetailsReadingReleased:
		case DetailsReadingCopyright:
		case DetailsReadingVersion:
		case DetailsReadingSize:
		case DetailsReadingPrice:
		case DetailsReadingCustomerRatings:
		case DetailsReadingCurrentRatingsNotEnoughReceived:
		case DetailsReadingCurrentRatingsNotEnoughReceivedDuplicate:
		case DetailsReadingCurrentRatingsTitle:
		case DetailsReadingCurrentRatingsCount:
		case DetailsReadingCurrentRatingsFiveStarsCount:
		case DetailsReadingCurrentRatingsFourStarsCount:
		case DetailsReadingCurrentRatingsThreeStarsCount:
		case DetailsReadingCurrentRatingsTwoStarsCount:
		case DetailsReadingCurrentRatingsOneStarCount:
		case DetailsReadingAllRatingsNotEnoughReceived:
		case DetailsReadingAllRatingsNotEnoughReceivedDuplicate:
		case DetailsReadingAllRatingsTitle:
		case DetailsReadingAllRatingsCount:
		case DetailsReadingAllRatingsFiveStarsCount:
		case DetailsReadingAllRatingsFourStarsCount:
		case DetailsReadingAllRatingsThreeStarsCount:
		case DetailsReadingAllRatingsTwoStarsCount:
		case DetailsReadingAllRatingsOneStarCount:
		case DetailsReadingRateThisSoftware:
		case DetailsReadingCustomerReviews:
		case DetailsReadingCurrentReviewsCount:
		case DetailsReadingAllReviewsCount:
		case DetailsReadingWriteReview:
			[currentString appendString:string];
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	NSString *elementNameLower = [elementName lowercaseString];
	if ([elementNameLower isEqualToString:@"b"] || [elementNameLower isEqualToString:@"setfontstyle"] || [elementNameLower isEqualToString:@"pathelement"])
	{
		PSLogDebug(@"Read <%@> content: [%@]", elementNameLower, currentString);
		switch (xmlState)
		{
			case DetailsReadingAppGenre:
			{
				if ([elementNameLower isEqualToString:@"pathelement"])
				{
					GTMRegex *regex = [GTMRegex regexWithPattern:@".*/viewGenre[?]id=([0-9][0-9][0-9][0-9]+).*"];
					NSArray *substrings = [regex subPatternsOfString:currentString];
					if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
					{
						self.categoryIdentifier = [substrings objectAtIndex:1];
						xmlState = DetailsSeekingCategory;
					}
					else
						xmlState = DetailsSeekingAppGenre;
				}
				break;
			}
			case DetailsReadingCategory:
			{
				// We don't use this value.
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasPrefix:@"Category: "])
					xmlState = DetailsSeekingReleased;
				else
					xmlState = DetailsSeekingCategory;
				[currentString setString:@""];
				break;
			}
			case DetailsReadingReleased:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^[ ]*([^ ]+)[ ]+([^ ].*[^ ]).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					self.released = [substrings objectAtIndex:2];
				}
				else
					self.released = @"";
				[currentString setString:@""];
				xmlState = DetailsSeekingCopyright;
				break;
			}
			case DetailsReadingCopyright:
				// We don't use this value.
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasPrefix:@"Seller: "])
					xmlState = DetailsSeekingCopyright;
				else
					xmlState = DetailsSeekingVersion;
				[currentString setString:@""];
				break;
			case DetailsReadingVersion:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^[ ]*([^ ][^:]*):[ ]*([^ ]+)(.*)"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					self.appVersion = [substrings objectAtIndex:2];
				}
				else
					self.appVersion = @"";
				[currentString setString:@""];
				xmlState = DetailsSeekingSize;
				break;
			}
			case DetailsReadingSize:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^[ ]*([^ ].*[^ ]).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]))
				{
					self.appSize = [substrings objectAtIndex:1];
				}
				else
					self.appSize = @"";
				[currentString setString:@""];
				xmlState = DetailsSeekingPrice;
				break;
			}
			case DetailsReadingPrice:
				self.localPrice = currentString;
				[currentString setString:@""];
				xmlState = DetailsSeekingCustomerRatings;
				break;
			case DetailsReadingCustomerRatings:
				// Skip over the "Rated X for:" message.
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString isEqualToString:@"CUSTOMER RATINGS"])
				{
					[currentString setString:@""];
					xmlState = DetailsSeekingCurrentRatingsDisclosure;
					skippingCollapsedDisclosure = NO;
				}
				else
					xmlState = DetailsSeekingCustomerRatings;
				break;
			case DetailsReadingCurrentRatingsNotEnoughReceived:
			{
				// We don't use this value.
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentRatingsNotEnoughReceivedDuplicate;
				break;
			}
			case DetailsReadingCurrentRatingsNotEnoughReceivedDuplicate:
			{
				// We don't use this value.
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsDisclosure;
				skippingCollapsedDisclosure = NO;
				break;
			}
			case DetailsReadingCurrentRatingsTitle:
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasSuffix:@":"])
					xmlState = DetailsSeekingCurrentAverageRating;
				else
				{
					[currentString setString:@""];
					xmlState = DetailsSeekingAllRatingsDisclosure;
				}
				break;
			case DetailsReadingCurrentRatingsCount:
			{
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^([0-9]+)[^0-9].*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.ratingCountCurrent = [count integerValue];
				}
				xmlState = DetailsSeekingCurrentRatingsFiveStarsCount;
				break;
			}
			case DetailsReadingCurrentRatingsFiveStarsCount:
			{
				self.ratingCountCurrent5Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentRatingsFourStarsCount;
				break;
			}
			case DetailsReadingCurrentRatingsFourStarsCount:
			{
				self.ratingCountCurrent4Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentRatingsThreeStarsCount;
				break;
			}
			case DetailsReadingCurrentRatingsThreeStarsCount:
			{
				self.ratingCountCurrent3Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentRatingsTwoStarsCount;
				break;
			}
			case DetailsReadingCurrentRatingsTwoStarsCount:
			{
				self.ratingCountCurrent2Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentRatingsOneStarCount;
				break;
			}
			case DetailsReadingCurrentRatingsOneStarCount:
			{
				self.ratingCountCurrent1Star = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsDisclosure;
				skippingCollapsedDisclosure = NO;
				break;
			}
			case DetailsReadingAllRatingsNotEnoughReceived:
			{
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasSuffix:@":"])
				{
					// No "All versions" ratings section.
					xmlState = DetailsSeekingCustomerReviews;
					multipleVersions = NO;
				}
				else
				{
					[currentString setString:@""];
					xmlState = DetailsSeekingAllRatingsNotEnoughReceivedDuplicate;
				}
				break;
			}
			case DetailsReadingAllRatingsNotEnoughReceivedDuplicate:
			{
				// We don't use this value.
				[currentString setString:@""];
				xmlState = DetailsSeekingRateThisSoftware;
				skippingCollapsedDisclosure = NO;
				break;
			}
			case DetailsReadingAllRatingsTitle:
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasSuffix:@":"])
					xmlState = DetailsSeekingAllAverageRating;
				else
				{
					[currentString setString:@""];
					xmlState = DetailsSeekingRateThisSoftware;
				}
				break;
			case DetailsReadingAllRatingsCount:
			{
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^([0-9]+)[^0-9].*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.ratingCountAll = [count integerValue];
				}
				xmlState = DetailsSeekingAllRatingsFiveStarsCount;
				break;
			}
			case DetailsReadingAllRatingsFiveStarsCount:
			{
				self.ratingCountAll5Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsFourStarsCount;
				break;
			}
			case DetailsReadingAllRatingsFourStarsCount:
			{
				self.ratingCountAll4Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsThreeStarsCount;
				break;
			}
			case DetailsReadingAllRatingsThreeStarsCount:
			{
				self.ratingCountAll3Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsTwoStarsCount;
				break;
			}
			case DetailsReadingAllRatingsTwoStarsCount:
			{
				self.ratingCountAll2Stars = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingAllRatingsOneStarCount;
				break;
			}
			case DetailsReadingAllRatingsOneStarCount:
			{
				self.ratingCountAll1Star = [currentString integerValue];
				[currentString setString:@""];
				xmlState = DetailsSeekingRateThisSoftware;
				break;
			}
			case DetailsReadingRateThisSoftware:
				CFStringTrimWhitespace((CFMutableStringRef)currentString);
				if ([currentString hasSuffix:@":"])
					xmlState = DetailsSeekingCustomerReviews;
				else
				{
					[currentString setString:@""];
					xmlState = DetailsSeekingRateThisSoftware;
				}
				break;
			case DetailsReadingCustomerReviews:
			{
				// We don't use this value.
				[currentString setString:@""];
				xmlState = DetailsSeekingCurrentReviewsCountURL;
				break;
			}
			case DetailsReadingCurrentReviewsCount:
			{
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^([0-9]+)[^0-9].*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.reviewCountCurrent = [count integerValue];
				}
				else
				{
					// We have >0 current reviews, but no number given, which seems to mean 1 only.
					self.reviewCountCurrent = 1;
				}
				xmlState = DetailsSeekingAllReviewsCount;
				break;
			}
			case DetailsReadingAllReviewsCount:
			{
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^([0-9]+)[^0-9].*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.reviewCountAll = [count integerValue];
				}
				else
				{
					// We have >0 reviews, but no number given, which seems to mean 1 only.
					self.reviewCountAll = 1;
				}
				xmlState = DetailsSeekingCompanyURL;
				break;
			}
			case DetailsReadingWriteReview:
			{
				// We don't use this value.
				[currentString setString:@""];
				xmlState = DetailsSeekingCompanyURL;
				break;
			}
		}
	}
}

@end
