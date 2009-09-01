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

#import "ACAppStoreVerifyOperation.h"
#import "ACAppStoreApplicationDetailsImporter.h"
#import "AppReviewsAppDelegate.h"
#import "PSLog.h"


@interface ACAppStoreVerifyOperation ()

- (NSData *)dataFromURL:(NSURL *)url;

@end


@implementation ACAppStoreVerifyOperation

@synthesize appIdentifier, storeIdentifier, detailsImporter, progressHUD;

- (id)initWithAppIdentifier:(NSString *)appId storeIdentifier:(NSString *)storeId;
{
	PSLogDebug(@"appIdentifier=%@, storeIdentifier=%@", appId, storeId);

	if (self = [super init])
	{
		self.appIdentifier = appId;
		self.storeIdentifier = storeId;
		detailsImporter = [[ACAppStoreApplicationDetailsImporter alloc] initWithAppIdentifier:appIdentifier storeIdentifier:storeIdentifier];
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

	// Send kACAppStoreVerifyOperationDidStartNotification to main thread.
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kACAppStoreVerifyOperationDidStartNotification object:detailsImporter] waitUntilDone:NO];

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
			// Send kACAppStoreVerifyOperationDidFinishNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kACAppStoreVerifyOperationDidFinishNotification object:self] waitUntilDone:YES];
		}
		else
		{
			// Send kACAppStoreVerifyOperationDidFailNotification to main thread.
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:kACAppStoreVerifyOperationDidFailNotification object:self] waitUntilDone:YES];
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

	AppReviewsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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
