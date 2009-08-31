//
//  PSHelpViewController.m
//  PSCommon
//
//  Created by Charles Gamble on 24/07/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSHelpViewController.h"
#import "PSLog.h"


@interface PSHelpViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)infoValueForKey:(NSString*)key;

@end


@implementation PSHelpViewController

@synthesize contentURL, viewTitle, webView;

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	self.title = @"Help";
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Release IBOutlets and items which can be recreated in viewDidLoad.
	self.webView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.viewTitle && [self.viewTitle length]>0)
		self.title = self.viewTitle;

	[webView loadRequest:[NSURLRequest requestWithURL:self.contentURL]];
}

- (void)dealloc
{
	[contentURL release];
	[viewTitle release];
	[webView release];
	[super dealloc];
}

// Fetch objects from our bundle based on keys in our Info.plist
- (id)infoValueForKey:(NSString*)key
{
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Help" message:@"Failed to load help text!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
