//
//  PSAppStoreReviews.m
//  AppCritics
//
//  Created by Charles Gamble on 22/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAppStoreReviews.h"
#import "PSAppStoreReview.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "AppCriticsAppDelegate.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "PSLog.h"


@implementation PSAppStoreReviews

@synthesize appId, storeId, released, appVersion, appSize, localPrice, appName, appCompany, countFound, countFirst, countLast, countTotal, averageRating, lastSortOrder, lastUpdated, reviews, downloadProgressHandler, downloadErrorMessage;

- (id)init
{
	return [self initWithAppId:nil storeId:nil];
}

- (id)initWithAppId:(NSString *)inAppId storeId:(NSString *)inStoreId
{
	if (self = [super init])
	{
		self.appId = inAppId;
		self.storeId = inStoreId;
		self.released = nil;
		self.appVersion = nil;
		self.appSize = nil;
		self.localPrice = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.countFound = 0;
		self.countFirst = 0;
		self.countLast = 0;
		self.countTotal = 0;
		self.averageRating = 0.0;
		self.lastSortOrder = [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		self.lastUpdated = [NSDate distantPast];
		self.reviews = nil;
		self.downloadProgressHandler = nil;
		self.downloadErrorMessage = nil;
		downloadCancelled = NO;
		downloadFileSize = NSURLResponseUnknownLength;
		downloadFileContents = nil;
		currentString = [[NSMutableString alloc] init];
		currentReviewSummary = nil;
		currentReviewRating = 0.0;
		currentReviewer = nil;
		currentReviewDetail = nil;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	// Parent class NSObject does not implement initWithCoder:
	if (self = [super init])
	{
		// Initialise persistent members.
		self.appId = [coder decodeObjectForKey:@"appId"];
		self.storeId = [coder decodeObjectForKey:@"storeId"];
		self.released = [coder decodeObjectForKey:@"released"];
		self.appVersion = [coder decodeObjectForKey:@"appVersion"];
		self.appSize = [coder decodeObjectForKey:@"appSize"];
		self.localPrice = [coder decodeObjectForKey:@"localPrice"];
		self.countTotal = [coder decodeIntegerForKey:@"countTotal"];
		self.averageRating = [coder decodeFloatForKey:@"averageRating"];
		self.lastSortOrder = [coder decodeIntegerForKey:@"lastSortOrder"];
		self.lastUpdated = [coder decodeObjectForKey:@"lastUpdated"];
		
		// Initialise non-persistent members.
		self.reviews = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.countFound = 0;
		self.countFirst = 0;
		self.countLast = 0;
		//self.reviews = [NSMutableArray array];
		self.downloadProgressHandler = nil;
		self.downloadErrorMessage = nil;
		downloadCancelled = NO;
		downloadFileSize = NSURLResponseUnknownLength;
		downloadFileContents = nil;
		currentString = [[NSMutableString alloc] init];
		currentReviewSummary = nil;
		currentReviewRating = 0.0;
		currentReviewer = nil;
		currentReviewDetail = nil;
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// Parent class NSObject does not implement encodeWithCoder:
	[encoder encodeObject:self.appId forKey:@"appId"];
	[encoder encodeObject:self.storeId forKey:@"storeId"];
	[encoder encodeObject:self.released forKey:@"released"];
	[encoder encodeObject:self.appVersion forKey:@"appVersion"];
	[encoder encodeObject:self.appSize forKey:@"appSize"];
	[encoder encodeObject:self.localPrice forKey:@"localPrice"];
	[encoder encodeInteger:self.countTotal forKey:@"countTotal"];
	[encoder encodeFloat:self.averageRating forKey:@"averageRating"];
	[encoder encodeInteger:self.lastSortOrder forKey:@"lastSortOrder"];
	[encoder encodeObject:self.lastUpdated forKey:@"lastUpdated"];
}

- (void)dealloc
{
	downloadCancelled = YES;
	[appId release];
	[storeId release];
	[released release];
	[appVersion release];
	[appSize release];
	[localPrice release];
	[appName release];
	[appCompany release];
	[lastUpdated release];
	[reviews release];
	[(id)downloadProgressHandler release];
	[downloadFileContents release];
	[downloadErrorMessage release];
	[currentString release];
	[currentReviewSummary release];
	[currentReviewer release];
	[currentReviewDetail release];
	[super dealloc];
}

- (void)downloadEnded
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Cleanup ready for future downloads
	downloadCancelled = NO;
	[downloadFileContents release];
	downloadFileContents = nil;
}

- (NSString *)localFilename
{
	NSString *documentsDirectory = [NSString documentsPath];
	NSString *result = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.archive", self.appId, self.storeId]];
	return result;
}

- (NSString *)localXMLFilename
{
	NSString *documentsDirectory = [NSString documentsPath];
	NSString *result = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.xml", self.appId, self.storeId]];
	return result;
}

- (void)saveReviews
{
	PSLogDebug(@"-->");
	
	// Don't save nil reviews.
	if (reviews)
	{
		// Build filename.
		NSString *documentFilename = [self localFilename];
		
		// Delete existing file.
		BOOL isDirectory = NO;
		if ( [[NSFileManager defaultManager] fileExistsAtPath:documentFilename isDirectory:&isDirectory] )
		{
			[[NSFileManager defaultManager] removeItemAtPath:documentFilename error:NULL];
		}
		
		// Write new file.
		PSLog(@"Saving reviews to: %@", documentFilename);
		if (![NSKeyedArchiver archiveRootObject:reviews toFile:documentFilename])
		{
			PSLogError(@"Could not save reviews for appId=%@, storeId=%@", appId, storeId);
		}
	}
	
	PSLogDebug(@"<--");
}

- (void)loadReviews
{
	PSLogDebug(@"-->");
	BOOL loaded = NO;
	
	// Build filename.
	NSString *documentFilename = [self localFilename];
	
	// Does file exist?
	BOOL isDirectory = NO;
	if ( [[NSFileManager defaultManager] fileExistsAtPath:documentFilename isDirectory:&isDirectory] )
	{
		NSMutableArray *newReviews;
		
		PSLog(@"Loading reviews from: %@", documentFilename);
		newReviews = [NSKeyedUnarchiver unarchiveObjectWithFile:documentFilename];
		if (newReviews)
		{
			self.reviews = newReviews;
			// We successfully read reviews from the file.
			loaded = YES;
		}
		else
		{
			PSLogError(@"Failed to load reviews for appId=%@, storeId=%@", appId, storeId);
		}
		
		PSLog(@"Loaded %d reviews for appId=%@, storeId=%@", [reviews count], appId, storeId);
	}
	else
	{
		// File does not exist.
		self.reviews = nil;
	}
	
	PSLogDebug(@"<--");
}

- (void)deleteReviews
{
	// Delete all review instances.
	[reviews removeAllObjects];
	
	// Delete the .archive file for this app/store.
	[[NSFileManager defaultManager] removeItemAtPath:[self localFilename] error:NULL];

	// Delete the .xml file for this app/store.
	[[NSFileManager defaultManager] removeItemAtPath:[self localXMLFilename] error:NULL];
}

- (void)fetchReviews:(id <PSProgressHandler>)progressHandler
{
	// Download the reviews.
	self.downloadProgressHandler = progressHandler;
	self.downloadErrorMessage = nil;
	downloadCancelled = NO;
	downloadFileSize = NSURLResponseUnknownLength;
	downloadFileContents = [[NSMutableData data] retain];
	
	NSURL *reviewsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=%d&type=Purple+Software", self.appId, [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"]]];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:reviewsURL
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	[theRequest setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:[NSString stringWithFormat:@" %@-1", self.storeId] forHTTPHeaderField:@"X-Apple-Store-Front"];

	NSDictionary *headerFields = [theRequest allHTTPHeaderFields];
	PSLogDebug([headerFields descriptionWithLocale:nil indent:2]);
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection)
	{
		// Download started.
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else
	{
		// Could not start download.
		PSLogError(@"Connection failed");
		[downloadFileContents release];
		downloadFileContents = nil;
	}
}

- (void)processReviews:(id <PSProgressHandler>)progressHandler
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
#ifdef DEBUG
	// Save XML file for debugging.
	[downloadFileContents writeToFile:[self localXMLFilename] atomically:YES];
#endif
	
	// Initialise some members used whilst parsing XML content.
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:downloadFileContents];
	xmlParser.delegate = self;
	xmlParser.shouldResolveExternalEntities = NO;
	xmlState = SeekingCompany;
	countFirst = 0;
	countLast = 0;
	[currentString setString:@""];
	currentReviewSummary = nil;
	currentReviewRating = 0.0;
	currentReviewer = nil;
	currentReviewDetail = nil;

	// Parse XML content.
	if ([xmlParser parse] == YES)
	{
		PSLog(@"Successfully parsed XML document");
		self.lastUpdated = [NSDate date];
		self.lastSortOrder = (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		// Save reviews out to file and reset to nil, they will be reloaded lazily.
		[self saveReviews];
		self.reviews = nil;
	}
	else
	{
		PSLog(@"Failed to parse XML document");
		self.reviews = nil;
	}
	
	[self downloadEnded];
	[xmlParser release];
	
	// Move on to next store.
	[[NSNotificationCenter defaultCenter] postNotificationName:PSAppStoreReviewsUpdatedNotification object:self];
	
	[pool release];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([[elementName lowercaseString] isEqualToString:@"b"] || [[elementName lowercaseString] isEqualToString:@"setfontstyle"])
	{
		[currentString setString:@""];
		switch (xmlState)
		{
			case SeekingCompany:
				xmlState = ReadingCompany;
				break;
			case SeekingAppName:
				xmlState = ReadingAppName;
				break;
			case SeekingPrice:
				xmlState = ReadingPrice;
				break;
			case SeekingWriteReview:
				xmlState = ReadingWriteReview;
				break;
			case SeekingAverageRatingLabel:
			case ReadingAverageRatingLabel:
				xmlState = ReadingAverageRatingLabel;
				break;
			case SeekingMostRecent:
			case ReadingMostRecent:
				xmlState = ReadingMostRecent;
				break;
			case SeekingCustomerReviews:
				xmlState = ReadingCustomerReviews;
				break;
			case SeekingSortBy:
				xmlState = ReadingSortBy;
				break;
			case SeekingMoreReviews:
				xmlState = ReadingMoreReviews;
				break;
			case SeekingSummary:
				xmlState = ReadingSummary;
				break;
			case SeekingNumFoundUseful:
				xmlState = ReadingNumFoundUseful;
				break;
			case SeekingReviewer:
				xmlState = ReadingReviewer;
				break;
			case SeekingHelpful:
				xmlState = ReadingHelpful;
				break;
			case SeekingYes:
				xmlState = ReadingYes;
				break;
			case SeekingYesNoSeparator:
				xmlState = ReadingYesNoSeparator;
				break;
			case SeekingNo:
				xmlState = ReadingNo;
				break;
			case SeekingReportConcern:
				xmlState = ReadingReportConcern;
				break;
			case SeekingCategory:
				xmlState = ReadingCategory;
				break;
			case SeekingReleased:
				xmlState = ReadingReleased;
				break;
			case SeekingCopyright:
				xmlState = ReadingCopyright;
				break;
			case SeekingVersion:
				xmlState = ReadingVersion;
				break;
			case SeekingSize:
				xmlState = ReadingSize;
				break;
			case SeekingReview:
				xmlState = ReadingReview;
				break;
		}
	}
	else if ([[elementName lowercaseString] isEqualToString:@"hboxview"])
	{
		switch (xmlState)
		{
			case SeekingAverageRatingValue:
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
					self.averageRating = ratingFloat;
				}
				else
				{
					// Didn't match regex.
					self.averageRating = 0.0;
				}
				xmlState = SeekingMostRecent;
				break;
			}
			case SeekingRating:
			{
				if ([attributeDict objectForKey:@"alt"])
				{
					NSString *rating = [[attributeDict objectForKey:@"alt"] copy];
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
					[rating release];
					xmlState = SeekingReviewer;
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
		case ReadingCompany:
		case ReadingAppName:
		case ReadingCategory:
		case ReadingReleased:
		case ReadingCopyright:
		case ReadingVersion:
		case ReadingSize:
		case ReadingPrice:
		case ReadingWriteReview:
		case ReadingAverageRatingLabel:
		case ReadingAverageRatingValue:
		case ReadingMostRecent:
		case ReadingCustomerReviews:
		case ReadingSortBy:
		case ReadingMoreReviews:
		case ReadingSummary:
		case ReadingRating:
		case ReadingNumFoundUseful:
		case ReadingReviewer:
		case ReadingReview:
		case ReadingHelpful:
		case ReadingYes:
		case ReadingYesNoSeparator:
		case ReadingNo:
		case ReadingReportConcern:
			[currentString appendString:string];
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([[elementName lowercaseString] isEqualToString:@"b"] || [[elementName lowercaseString] isEqualToString:@"setfontstyle"])
	{
		PSLogDebug(@"Read <b> content: [%@]", currentString);
		switch (xmlState)
		{
			case ReadingCompany:
			{
				self.appCompany = currentString;
				[currentString setString:@""];
				xmlState = SeekingAppName;
				break;
			}
			case ReadingAppName:
			{
				self.appName = currentString;
				[currentString setString:@""];
				xmlState = SeekingCategory;
				break;
			}
			case ReadingPrice:
				self.localPrice = currentString;
				[currentString setString:@""];
				xmlState = SeekingWriteReview;
				break;
			case ReadingWriteReview:
				// Check if we really did get the "WRITE A REVIEW" element and not the "Rated bla for:" element.
				if ([currentString isEqualToString:@"WRITE A REVIEW"])
					xmlState = SeekingAverageRatingLabel;
				else
					xmlState = SeekingWriteReview;
				[currentString setString:@""];
				break;
			case ReadingAverageRatingLabel:
				[currentString setString:@""];
				xmlState = SeekingAverageRatingValue;
				break;
			case ReadingMostRecent:
			{
				// Ratings with half values insert an extra <b> element.
				NSRange charPos = [currentString rangeOfString:@":"];
				if (charPos.location == NSNotFound)
					xmlState = SeekingMostRecent;
				else
					xmlState = SeekingCustomerReviews;				
				[currentString setString:@""];
				break;
			}
			case ReadingCustomerReviews:
			{
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^[^0-9]+([0-9]+)-([0-9]+)[^0-9]+([0-9]+)"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]) && ([substrings objectAtIndex:2] != [NSNull null]) && ([substrings objectAtIndex:3] != [NSNull null]))
				{
					NSString *thisPageFirst = [substrings objectAtIndex:1];
					NSString *thisPageLast = [substrings objectAtIndex:2];
					NSString *total = [substrings objectAtIndex:3];
					countFirst = [thisPageFirst integerValue];
					countLast = [thisPageLast integerValue];
					countTotal = [total integerValue];
					// For some reason iTunes sometimes reports 1 star average for a page with 0 reviews,
					// which looks weird, so we'll reset average to 0 if we have no reviews.
					if (countTotal <= 0)
						averageRating = 0.0;
					
					// We can abort parsing here if we only need the summary info and not the individual reviews.
					// [parser abortParsing];
					
					xmlState = SeekingSortBy;
				}
				else
					xmlState = SeekingCustomerReviews;
				[regex release];
				[currentString setString:@""];
				break;
			}
			case ReadingSortBy:
				// We don't use this value.
				[currentString setString:@""];
				// If there is more than one page of reviews there will be an extra "MORE REVIEWS" element.
				if (countLast < countTotal)
					xmlState = SeekingMoreReviews;
				else
					xmlState = SeekingSummary;
				break;
			case ReadingMoreReviews:
				// We don't use this value.
				[currentString setString:@""];
				xmlState = SeekingSummary;
				break;
			case ReadingSummary:
				currentReviewSummary = [currentString copy];
				[currentString setString:@""];
				xmlState = SeekingRating;
				break;
			case ReadingNumFoundUseful:
				[currentString setString:@""];
				xmlState = SeekingReviewer;
				break;
			case ReadingReviewer:
			{
				// Skip over the optional "1 out of 1 customers found this review helpful"
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^([0-9]+) out of ([0-9]+).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (substrings && [substrings count] > 0)
				{
					// We have matched the optional line that we need to skip.
					xmlState = SeekingReviewer;
				}
				else
				{
					GTMRegex *regexBy = [[GTMRegex alloc] initWithPattern:@"^by ([^ ].*[^ ]).*"];
					NSArray *substringsBy = [regexBy subPatternsOfString:currentString];
					if (substringsBy && ([substringsBy count] > 0) && ([substringsBy objectAtIndex:0] != [NSNull null]) && ([substringsBy objectAtIndex:1] != [NSNull null]))
						currentReviewer = [[substringsBy objectAtIndex:1] copy];
					else
						currentReviewer = [currentString copy];
					xmlState = SeekingReview;
					[regexBy release];
				}
				[regex release];
				[currentString setString:@""];
				break;
			}
			case ReadingHelpful:
				[currentString setString:@""];
				xmlState = SeekingYes;
				break;
			case ReadingYes:
				[currentString setString:@""];
				xmlState = SeekingYesNoSeparator;
				break;
			case ReadingYesNoSeparator:
				[currentString setString:@""];
				xmlState = SeekingNo;
				break;
			case ReadingNo:
				[currentString setString:@""];
				xmlState = SeekingReportConcern;
				break;
			case ReadingReportConcern:
			{
				NSUInteger maxReviewCount = 0;
				if (countTotal > 0)
					maxReviewCount = (countLast - countFirst) + 1;
				[currentString setString:@""];
				countFound++;
				// Store current review details and clear, ready for next review.
				if (countFound <= maxReviewCount)
				{
					PSAppStoreReview *review = [[PSAppStoreReview alloc] init];
					review.reviewer = currentReviewer;
					review.rating = currentReviewRating;
					review.summary = currentReviewSummary;
					review.detail = currentReviewDetail;
					review.index = countFirst + countFound - 1;
					if (self.reviews == nil)
						self.reviews = [NSMutableArray array];
					[self.reviews addObject:review];
					[review release];
					
					// Sometimes iTunes returns non-integer average ratings for stores with only 1 review,
					// which looks weird wo we'll correct it here.
					if (countTotal == 1)
						averageRating = currentReviewRating;
				}
				[currentReviewer release];
				currentReviewer = nil;
				currentReviewRating = 0.0;
				[currentReviewSummary release];
				currentReviewSummary = nil;
				[currentReviewDetail release];
				currentReviewDetail = nil;
				xmlState = SeekingSummary;
				break;
			}
			case ReadingCategory:
				// We don't use this value.
				[currentString setString:@""];
				xmlState = SeekingReleased;
				break;
			case ReadingReleased:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^[ ]*([^ ].*)[ ]{2,}([^ ].*[^ ]).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					self.released = [substrings objectAtIndex:2];
				}
				else
					self.released = @"";
				[regex release];
				[currentString setString:@""];
				xmlState = SeekingCopyright;
				break;
			}
			case ReadingCopyright:
				// We don't use this value.
				[currentString setString:@""];
				xmlState = SeekingVersion;
				break;
			case ReadingVersion:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^[ ]*([^ ][^:]*):[ ]*([^ ].*[^ ]).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					self.appVersion = [substrings objectAtIndex:2];
				}
				else
					self.appVersion = @"";
				[regex release];
				[currentString setString:@""];
				xmlState = SeekingSize;
				break;
			}
			case ReadingSize:
			{
				[currentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				[currentString replaceOccurrencesOfString:@"\t" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [currentString length])];
				GTMRegex *regex = [[GTMRegex alloc] initWithPattern:@"^[ ]*([^ ].*[^ ]).*"];
				NSArray *substrings = [regex subPatternsOfString:currentString];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]))
				{
					self.appSize = [substrings objectAtIndex:1];
				}
				else
					self.appSize = @"";
				[regex release];
				[currentString setString:@""];
				xmlState = SeekingPrice;
				break;
			}
			case ReadingReview:
				currentReviewDetail = [currentString copy];
				[currentString setString:@""];
				xmlState = SeekingHelpful;
				break;
		}
	}
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	PSLogDebug(@"-->");
	
	[[challenge sender] cancelAuthenticationChallenge:challenge];
	
	PSLogDebug(@"<--");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	PSLogDebug(@"-->");
	AppCriticsAppDelegate *appDelegate = (AppCriticsAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger statusCode = 0;
	
	downloadFileSize = [response expectedContentLength];
	PSLog(@"expectedContentLength=%d", downloadFileSize);
	PSLog(@"suggestedFilename=[%@]", ([response suggestedFilename]?[response suggestedFilename]:@"nil"));
	PSLog(@"MIMEtype=[%@]", ([response MIMEType]?[response MIMEType]:@"nil"));
	PSLog(@"textEncodingName=[%@]", ([response textEncodingName]?[response textEncodingName]:@"nil"));
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
		statusCode = [httpResponse statusCode];
		PSLog(@"statusCode=[%d] [%@]", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
	}
	
	if ((statusCode >= 400) || downloadCancelled || appDelegate.exiting)
	{
		// Error downloading file.
		[connection cancel];
		[connection release];
		[self downloadEnded];
		// Move on to next store.
		[[NSNotificationCenter defaultCenter] postNotificationName:PSAppStoreReviewsUpdatedNotification object:self];
	}
	else
	{
		// Reset data length and progress
		[downloadFileContents setLength:0];
		if (downloadProgressHandler)
		{
			if (downloadFileSize != NSURLResponseUnknownLength)
			{
				//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdate:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:YES];
			}
			//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdateMessage:) withObject:@"Connected" waitUntilDone:YES];
		}
	}
	
	PSLogDebug(@"<--");
}

-(NSURLRequest *)connection:(NSURLConnection*)connection
			willSendRequest:(NSURLRequest*)request
		   redirectResponse:(NSURLResponse*)redirectResponse
{
    NSMutableURLRequest *newReq = [request mutableCopy];
    [newReq setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[newReq setValue:[NSString stringWithFormat:@"%@-1", self.storeId] forHTTPHeaderField:@"X-Apple-Store-Front"];
    return [newReq autorelease];
} 

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	PSLogDebug(@"-->");
	AppCriticsAppDelegate *appDelegate = (AppCriticsAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	if (downloadCancelled || appDelegate.exiting)
	{
		[connection cancel];
		[connection release];
		[self downloadEnded];
		// Move on to next store.
		[[NSNotificationCenter defaultCenter] postNotificationName:PSAppStoreReviewsUpdatedNotification object:self];
	}
	else
	{
		// Concatenate the new data with the existing data to build up the downloaded file
		// Update the status of the download
		[downloadFileContents appendData:data];
		
		if (downloadProgressHandler)
		{
			if (downloadFileSize != NSURLResponseUnknownLength)
			{
				//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdate:) withObject:[NSNumber numberWithFloat:(float)[downloadFileContents length] / (float)downloadFileSize] waitUntilDone:YES];
			}
			
			//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdateMessage:) withObject:@"Processing App Reviews" waitUntilDone:YES];
		}
	}
	PSLogDebug(@"<--");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	PSLogDebug(@"-->");
	
	PSLog(@"Download succeeded - Received %d bytes of data", [downloadFileContents length]);
    [connection release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (downloadProgressHandler)
	{
		if (downloadFileSize != NSURLResponseUnknownLength)
		{
			//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdate:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:YES];
		}
		//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdateMessage:) withObject:@"Download Completed" waitUntilDone:YES];
	}
	
	// Data is now complete:
	
	// Process data on new thread, using same progress display.
	[NSThread detachNewThreadSelector:@selector(processReviews:) toTarget:self withObject:downloadProgressHandler];
	
	PSLogDebug(@"<--");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	PSLogDebug(@"-->");
	
    PSLogError(@"Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    [connection release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (downloadProgressHandler)
	{
		//[(id)downloadProgressHandler performSelectorOnMainThread:@selector(progressUpdateMessage:) withObject:@"Failed" waitUntilDone:YES];
	}
	
	[self downloadEnded];
	
	// Clear out app name and company to reflect that we failed.
	self.appName = nil;
	self.appCompany = nil;
	
	// Move on to next store.
	[[NSNotificationCenter defaultCenter] postNotificationName:PSAppStoreReviewsUpdatedNotification object:self];

	PSLogDebug(@"<--");
}

@end
