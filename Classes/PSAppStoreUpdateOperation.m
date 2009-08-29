//
//  PSAppStoreUpdateOperation.m
//  AppCritics
//
//  Created by Charles Gamble on 19/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreUpdateOperation.h"
#import "PSAppStoreApplicationDetails.h"
#import "PSAppStoreApplicationDetailsImporter.h"
#import "PSAppStoreApplicationReviewsImporter.h"
#import "PSLog.h"


@interface PSAppStoreUpdateOperation ()

- (NSData *)dataFromURL:(NSURL *)url;

@end


@implementation PSAppStoreUpdateOperation

@synthesize appDetails, fetchReviews, detailsImporter, reviewsImporter;

- (id)initWithApplicationDetails:(PSAppStoreApplicationDetails *)details
{
	PSLogDebug(@"appIdentifier=%@, storeIdentifier=%@", details.appIdentifier, details.storeIdentifier);

	if (self = [super init])
	{
		appDetails = [details retain];
		detailsImporter = [[PSAppStoreApplicationDetailsImporter alloc] initWithAppIdentifier:details.appIdentifier storeIdentifier:details.storeIdentifier];
		reviewsImporter = [[PSAppStoreApplicationReviewsImporter alloc] initWithAppIdentifier:details.appIdentifier storeIdentifier:details.storeIdentifier];
		fetchReviews = YES;
	}
	return self;
}

- (void)dealloc
{
	PSLogDebug(@"");
	[appDetails release];
	[detailsImporter release];
	[reviewsImporter release];
	[super dealloc];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PSLogDebug(@"isCancelled=%@", ([self isCancelled] ? @"YES" : @"NO"));

	BOOL success = YES;

	// Update state.
	appDetails.state = PSAppStoreStateProcessing;
	// Send kPSAppStoreUpdateOperationDidStartNotification to main thread.
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreUpdateOperationDidStartNotification object:appDetails] waitUntilDone:YES];

	// Fetch app details.
	if (![self isCancelled])
	{
		NSURL *detailsURL = [detailsImporter detailsURL];
		NSData *data = [self dataFromURL:detailsURL];
		if (data)
		{
			// Downloaded OK, now parse XML data.
			if (![self isCancelled])
			{
				[detailsImporter processDetails:data];
				if (detailsImporter.importState != DetailsImportStateComplete)
					success = NO;
			}
		}
		else
			success = NO;

		// Fetch app reviews.
		if (success && fetchReviews)
		{
			NSURL *reviewsURL = [reviewsImporter reviewsURL];
			if (![self isCancelled])
			{
				NSData *data = [self dataFromURL:reviewsURL];
				if (data)
				{
					// Downloaded OK, now parse XML data.
					if (![self isCancelled])
					{
						[reviewsImporter processReviews:data];
						if ((reviewsImporter.importState != ReviewsImportStateComplete) && (reviewsImporter.importState != ReviewsImportStateEmpty))
							success = NO;
					}
				}
			}
		}
	}

	if (![self isCancelled])
	{
		if (success)
		{
			// Save if all successful.
			[self performSelectorOnMainThread:@selector(save:) withObject:self waitUntilDone:YES];
			appDetails.state = PSAppStoreStateDefault;
			// Send kPSAppStoreUpdateOperationDidFinishNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreUpdateOperationDidFinishNotification object:appDetails] waitUntilDone:YES];
		}
		else
		{
			appDetails.state = PSAppStoreStateFailed;
			// Send kPSAppStoreUpdateOperationDidFailNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreUpdateOperationDidFailNotification object:appDetails] waitUntilDone:YES];
		}
	}
	else
		appDetails.state = PSAppStoreStateDefault;

	[pool drain];
}

- (NSData *)dataFromURL:(NSURL *)url
{
	PSLogDebug(@"url=%@", url);
	NSData *result = nil;
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:10.0];
	[theRequest setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:[NSString stringWithFormat:@" %@-1", appDetails.storeIdentifier] forHTTPHeaderField:@"X-Apple-Store-Front"];

#ifdef DEBUG
	NSDictionary *headerFields = [theRequest allHTTPHeaderFields];
	PSLogDebug([headerFields descriptionWithLocale:nil indent:2]);
#endif

	AppCriticsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate performSelectorOnMainThread:@selector(increaseNetworkUsageCount) withObject:nil waitUntilDone:YES];
	result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	[appDelegate performSelectorOnMainThread:@selector(decreaseNetworkUsageCount) withObject:nil waitUntilDone:YES];
	if (result==nil && error)
	{
		PSLogError(@"URL request failed with error: %@", error);
	}
	return result;
}

// Called on main thread to prevent db issues.
- (void)save:(id)object
{
	PSLogDebug(@"-->");
	PSAppStoreApplication *appStoreApplication = [[PSAppReviewsStore sharedInstance] applicationForIdentifier:appDetails.appIdentifier];
	PSAppStore *store = [[PSAppReviewsStore sharedInstance] storeForIdentifier:detailsImporter.storeIdentifier];
	// Save details info for this app/store.
	NSUInteger oldRatingsCount = appDetails.ratingCountAll;
	NSUInteger oldReviewsCount = appDetails.reviewCountAll;
	[detailsImporter copyDetailsTo:appDetails];
	NSUInteger newRatingsCount = appDetails.ratingCountAll;
	NSUInteger newReviewsCount = appDetails.reviewCountAll;
	if (newRatingsCount != oldRatingsCount)
		appDetails.hasNewRatings = YES;
	if (newReviewsCount != oldReviewsCount)
		appDetails.hasNewReviews = YES;
	[appDetails save];

	// Save reviews for this app/store.
	if (fetchReviews)
	{
		NSArray *reviews = [reviewsImporter reviews];
		[[PSAppReviewsStore sharedInstance] setReviews:reviews forApplication:appStoreApplication inStore:store];
	}
	PSLogDebug(@"<--");
}

@end
