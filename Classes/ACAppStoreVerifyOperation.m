//
//  PSAppStoreVerifyOperation.m
//  AppCritics
//
//  Created by Charles Gamble on 21/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import "PSAppStoreVerifyOperation.h"
#import "PSAppStoreApplicationDetailsImporter.h"
#import "AppCriticsAppDelegate.h"
#import "PSLog.h"


@interface PSAppStoreVerifyOperation ()

- (NSData *)dataFromURL:(NSURL *)url;

@end


@implementation PSAppStoreVerifyOperation

@synthesize appIdentifier, storeIdentifier, detailsImporter, progressHUD;

- (id)initWithAppIdentifier:(NSString *)appId storeIdentifier:(NSString *)storeId;
{
	PSLogDebug(@"appIdentifier=%@, storeIdentifier=%@", appId, storeId);

	if (self = [super init])
	{
		self.appIdentifier = appId;
		self.storeIdentifier = storeId;
		detailsImporter = [[PSAppStoreApplicationDetailsImporter alloc] initWithAppIdentifier:appIdentifier storeIdentifier:storeIdentifier];
	}
	return self;
}

- (void)dealloc
{
	PSLogDebug(@"");
	[appIdentifier release];
	[storeIdentifier release];
	[detailsImporter release];
	[progressHUD release];
	[super dealloc];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PSLogDebug(@"isCancelled=%@", ([self isCancelled] ? @"YES" : @"NO"));

	BOOL success = YES;

	// Send kPSAppStoreVerifyOperationDidStartNotification to main thread.
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreVerifyOperationDidStartNotification object:detailsImporter] waitUntilDone:NO];

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
	}

	if (![self isCancelled])
	{
		if (success)
		{
			// Send kPSAppStoreVerifyOperationDidFinishNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreVerifyOperationDidFinishNotification object:self] waitUntilDone:YES];
		}
		else
		{
			// Send kPSAppStoreVerifyOperationDidFailNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kPSAppStoreVerifyOperationDidFailNotification object:self] waitUntilDone:YES];
		}
	}

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
	[theRequest setValue:[NSString stringWithFormat:@" %@-1", storeIdentifier] forHTTPHeaderField:@"X-Apple-Store-Front"];

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

@end
