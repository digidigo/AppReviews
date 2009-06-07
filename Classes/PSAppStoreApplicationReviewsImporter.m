//
//  PSAppStoreApplicationReviewsImporter.m
//  AppCritics
//
//  Created by Charles Gamble on 09/04/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreApplicationReviewsImporter.h"
#import "PSAppStoreApplicationReview.h"
#import "PSAppStoreApplication.h"
#import "PSAppStore.h"
#import "AppCriticsAppDelegate.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "PSLog.h"


@implementation PSAppStoreApplicationReviewsImporter

@synthesize appIdentifier, storeIdentifier;
@synthesize importState, downloadErrorMessage;

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
		self.downloadErrorMessage = nil;
		downloadCancelled = NO;
		downloadFileSize = NSURLResponseUnknownLength;
		downloadFileContents = nil;
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
	downloadCancelled = YES;
	[appIdentifier release];
	[storeIdentifier release];
	[downloadFileContents release];
	[downloadErrorMessage release];
	[currentString release];
	[currentReviewSummary release];
	[currentReviewer release];
	[currentReviewVersion release];
	[currentReviewDate release];
	[currentReviewDetail release];
	[reviews release];
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

- (void)fetchReviews
{
	// Download the reviews.
	self.importState = ReviewsImportStateDownloading;
	self.downloadErrorMessage = nil;
	downloadCancelled = NO;
	downloadFileSize = NSURLResponseUnknownLength;
	downloadFileContents = [[NSMutableData data] retain];
	NSURL *reviewsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=%d&type=Purple+Software&onlyLatestVersion=false", self.appIdentifier, [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"]]];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:reviewsURL
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:10.0];
	[theRequest setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:[NSString stringWithFormat:@" %@-1", self.storeIdentifier] forHTTPHeaderField:@"X-Apple-Store-Front"];

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
		importState = ReviewsImportStateDownloadFailed;
	}
}

- (void)processReviews
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PSLogDebug(@"-->");

#ifdef DEBUG
	// Save XML file for debugging.
	[downloadFileContents writeToFile:[self localXMLFilename] atomically:YES];
#endif

	// Initialise some members used whilst parsing XML content.
	self.importState = ReviewsImportStateParsing;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:downloadFileContents];
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

	[self downloadEnded];
	[xmlParser release];

	// Move on to next store.
	[[NSNotificationCenter defaultCenter] postNotificationName:kPSAppStoreApplicationReviewsUpdatedNotification object:self];

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
				PSAppStoreApplicationReview *thisReview = [[PSAppStoreApplicationReview alloc] initWithAppIdentifier:appIdentifier storeIdentifier:storeIdentifier];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:kPSAppStoreApplicationReviewsUpdatedNotification object:self];
	}
	else
	{
		// Reset data length and progress
		[downloadFileContents setLength:0];
	}

	PSLogDebug(@"<--");
}

-(NSURLRequest *)connection:(NSURLConnection*)connection
			willSendRequest:(NSURLRequest*)request
		   redirectResponse:(NSURLResponse*)redirectResponse
{
    NSMutableURLRequest *newReq = [request mutableCopy];
    [newReq setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[newReq setValue:[NSString stringWithFormat:@"%@-1", self.storeIdentifier] forHTTPHeaderField:@"X-Apple-Store-Front"];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:kPSAppStoreApplicationReviewsUpdatedNotification object:self];
	}
	else
	{
		// Concatenate the new data with the existing data to build up the downloaded file
		// Update the status of the download
		[downloadFileContents appendData:data];
	}
	PSLogDebug(@"<--");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	PSLogDebug(@"-->");

	PSLog(@"Download succeeded - Received %d bytes of data", [downloadFileContents length]);
    [connection release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	// Data is now complete:

	// Process data on new thread, using same progress display.
	[NSThread detachNewThreadSelector:@selector(processReviews) toTarget:self withObject:nil];

	PSLogDebug(@"<--");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	PSLogDebug(@"-->");

    PSLogError(@"Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    [connection release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	[self downloadEnded];

	// Set state to reflect that we failed.
	self.importState = ReviewsImportStateDownloadFailed;

	// Move on to next store.
	[[NSNotificationCenter defaultCenter] postNotificationName:kPSAppStoreApplicationReviewsUpdatedNotification object:self];

	PSLogDebug(@"<--");
}

@end
