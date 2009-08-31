//
//	Copyright (c) 2008-2009, AppCritics
//	http://github.com/gambcl/AppCritics
//	http://www.perculasoft.com/appcritics
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
//	* Neither the name of AppCritics nor the names of its contributors may be used
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

#import "PSAboutViewController.h"
#import "PSHelpViewController.h"
#import "PSLog.h"


#define kOpenWebsiteURLTagValue			1
#define kOpenReleaseNotesURLTagValue	2


typedef enum
{
	PSAboutApplicationRow,
	PSAboutVersionRow,
	PSAboutCopyrightRow,
	PSAboutCreditsRow,
	PSAboutWebsiteRow,
	PSAboutFeedbackEmailRow,
	PSAboutRecommendEmailRow
} PSAboutRow;


@interface PSAboutViewController ()

@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) UIImage *appIcon;
@property (nonatomic, retain) NSString *appVersion;
@property (nonatomic, retain) NSString *copyright;
@property (nonatomic, retain) NSString *creditsURL;
@property (nonatomic, retain) NSString *websiteURL;
@property (nonatomic, retain) NSString *appURL;
@property (nonatomic, retain) NSString *releaseNotesURL;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSMutableArray *rowTypes;

- (id)infoValueForKey:(NSString*)key;
- (NSString *)pathForIcon;

@end


@implementation PSAboutViewController

@synthesize appName, appIcon, appVersion, copyright, creditsURL, websiteURL, appURL, releaseNotesURL, email, appId, applicationNameFontSize, parentViewForConfirmation, rowTypes;


/**
 * Initializer.
 */
- (id)init
{
	return [self initWithParentViewForConfirmation:nil style:UITableViewStyleGrouped];
}

/**
 * Initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView
{
	return [self initWithParentViewForConfirmation:parentView style:UITableViewStyleGrouped];
}

/**
 * Initializer.
 */
- (id)initWithStyle:(UITableViewStyle)style
{
	return [self initWithParentViewForConfirmation:nil style:style];
}

/**
 * Designated initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView style:(UITableViewStyle)style
{
	NSAssert(style==UITableViewStyleGrouped, @"PSAboutViewController only supports UITableViewStyleGrouped");

    if (self = [super initWithStyle:style])
	{
		self.parentViewForConfirmation = parentView;
    }
    return self;
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	self.title = NSLocalizedString(@"About", @"About");
	self.appName = [self infoValueForKey:@"CFBundleDisplayName"];
	self.appVersion = [self infoValueForKey:@"CFBundleVersion"];
	self.copyright = [self infoValueForKey:@"NSHumanReadableCopyright"];
	self.creditsURL = [self infoValueForKey:@"PSCreditsURL"];
	self.websiteURL = [self infoValueForKey:@"PSWebsiteURL"];
	self.appURL = [self infoValueForKey:@"PSApplicationURL"];
	self.releaseNotesURL = [self infoValueForKey:@"PSReleaseNotesURL"];
	self.email = [self infoValueForKey:@"PSContactEmail"];
	self.appId = [self infoValueForKey:@"PSApplicationID"];
	NSString *iconFilePath = [self pathForIcon];
	if (iconFilePath && [iconFilePath length] > 0)
		self.appIcon = [UIImage imageWithContentsOfFile:iconFilePath];
	self.applicationNameFontSize = 28.0;
	// Build an array of row types.
	self.rowTypes = [NSMutableArray array];
	// First row is always app name.
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutApplicationRow]];
	// Second row is always app version.
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutVersionRow]];
	// Optional copyright row.
	if (self.copyright && [self.copyright length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutCopyrightRow]];
	// Optional credits row.
	if (self.creditsURL && [self.creditsURL length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutCreditsRow]];
	// Optional website row.
	if (self.websiteURL && [self.websiteURL length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutWebsiteRow]];
	// Optional feedback row.
	if (self.email && [self.email length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutFeedbackEmailRow]];
	// Final row is always "Send to a friend".
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutRecommendEmailRow]];
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Release IBOutlets and items which can be recreated in viewDidLoad.
	self.appName = nil;
	self.appVersion = nil;
	self.copyright = nil;
	self.creditsURL = nil;
	self.websiteURL = nil;
	self.appURL = nil;
	self.releaseNotesURL = nil;
	self.email = nil;
	self.appId = nil;
	self.appIcon = nil;
	self.rowTypes = nil;
}

/**
 * Destructor.
 */
- (void)dealloc
{
	PSLogDebug(@"");
	[appName release];
	[appIcon release];
	[appVersion release];
	[copyright release];
	[creditsURL release];
	[websiteURL release];
	[appURL release];
	[releaseNotesURL release];
	[email release];
	[appId release];
	[parentViewForConfirmation release];
	[rowTypes release];
    [super dealloc];
}

/**
 * Fetch objects from our bundle based on keys in our Info.plist
 *
 * @param key The key to look for in the Info.plist.
 *
 * @return Object found for key in Info.plist, otherwise nil if nothing found.
 */
- (id)infoValueForKey:(NSString*)key
{
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

/**
 * Constructs a path to the icon file to be displayed in the About view.
 * Looks at the UIPrerenderedIcon setting in Info.plist and if a pre-rendered icon
 * is supplied then that is used. Next we look for an icon file specified by
 * PSAboutIconFile in the Info.plist file before finally defaulting to CFBundleIconFile.
 */
- (NSString *)pathForIcon
{
	NSString *iconFile = nil;

	//UIPrerenderedIcon
	CFBooleanRef prerenderedFlag = (CFBooleanRef) [self infoValueForKey:@"UIPrerenderedIcon"];
	if ((prerenderedFlag == nil) || (CFBooleanGetValue(prerenderedFlag) == false))
	{
		// App has a plain icon, look for a specific icon for the About view.
		iconFile = [self infoValueForKey:@"PSAboutIconFile"];
	}

	if (iconFile == nil)
	{
		// Use default app icon if nothing better found.
		iconFile = [self infoValueForKey:@"CFBundleIconFile"];
	}

	NSString *iconExt = [iconFile pathExtension];
	if (iconExt && [iconExt length] > 0)
		iconFile = [iconFile substringToIndex:([iconFile length] - ([iconExt length] + 1))];

	return [[NSBundle mainBundle] pathForResource:iconFile ofType:iconExt];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutVersionRow:
		case PSAboutCreditsRow:
		case PSAboutWebsiteRow:
		case PSAboutFeedbackEmailRow:
		case PSAboutRecommendEmailRow:
			return indexPath;
	}

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	if (rowType == PSAboutApplicationRow)
		return 67.0;
	return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIActionSheet *sheet = nil;

	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutCreditsRow:
		{
			// Create the credits view controller.
			PSHelpViewController *creditsViewController = [[[PSHelpViewController alloc] initWithNibName:@"PSHelpView" bundle:nil] autorelease];
			creditsViewController.hidesBottomBarWhenPushed = YES;
			creditsViewController.viewTitle = @"Credits";
			// Set the content.
			NSString *creditsFile = [self.creditsURL stringByDeletingPathExtension];
			NSString *creditsExt = [self.creditsURL pathExtension];
			NSString *contentPath = [[NSBundle mainBundle] pathForResource:creditsFile ofType:creditsExt];
			NSAssert2(contentPath != nil, @"Could not locate resource file %@.%@", creditsFile, creditsExt);
			NSURL *contentURL = [NSURL fileURLWithPath:contentPath];
			creditsViewController.contentURL = contentURL;
			// Show the content.
			[self.navigationController pushViewController:creditsViewController animated:YES];
			break;
		}
		case PSAboutWebsiteRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:websiteURL delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Visit Website", @"Visit Website"), nil];
			sheet.tag = kOpenWebsiteURLTagValue;
			break;
		}
		case PSAboutVersionRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"View Release Notes", @"View Release Notes"), nil];
			sheet.tag = kOpenReleaseNotesURLTagValue;
			break;
		}
		case PSAboutFeedbackEmailRow:
		{
			// Check that email is configured on device
			if ([MFMailComposeViewController canSendMail])
			{
				MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
				mailVC.mailComposeDelegate = self;
				[mailVC setSubject:[NSString stringWithFormat:@"%@ Feedback (version %@)", appName, appVersion]];
				[mailVC setToRecipients:[NSArray arrayWithObject:email]];
				[self presentModalViewController:mailVC animated:YES];
			}
			else
			{
				// Email not configured on device.
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
																message:NSLocalizedString(@"Email has not been configured on this device!", @"Email has not been configured on this device!")
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			break;
		}
		case PSAboutRecommendEmailRow:
		{
			// Check that email is configured on device
			if ([MFMailComposeViewController canSendMail])
			{
				NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"I thought you might be interested in %@", @"I thought you might be interested in %@"), appName];
				NSString *body = nil;
				if (appId && [appId length] > 0)
				{
					// We have the appId, provide a link to the app's page in the App Store.
					NSURL *homeURL = [NSURL URLWithString:appURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", appURL]];
					}

					body = [NSString stringWithFormat:@"%@:\nhttp://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@\n\n%@:\n%@", NSLocalizedString(@"Available in the App Store", @"Available in the App Store"), appId, NSLocalizedString(@"For more information",@"For more information"), [homeURL absoluteString]];
				}
				else if (appURL)
				{
					// We don't have the appId, provide a link to the app's home page.
					NSURL *homeURL = [NSURL URLWithString:appURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", appURL]];
					}
					body = [homeURL absoluteString];
				}
				else
				{
					// We don't have the appId or the app's home page, provide a link to the company's home page.
					NSURL *homeURL = [NSURL URLWithString:websiteURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", websiteURL]];
					}
					body = [homeURL absoluteString];
				}
				MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
				mailVC.mailComposeDelegate = self;
				[mailVC setSubject:subject];
				[mailVC setMessageBody:body isHTML:NO];
				[self presentModalViewController:mailVC animated:YES];
			}
			else
			{
				// Email not configured on device.
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
																message:NSLocalizedString(@"Email has not been configured on this device!", @"Email has not been configured on this device!")
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			break;
		}
		default:
		{
			// Deselect table row.
			[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
			break;
		}
	}

	if (sheet)
	{
		// Determine what the parent view is, for the UIActionSheet.
		UIView *parentView = self.parentViewForConfirmation;
		if (parentView == nil)
			parentView = self.tableView;

		if ([parentView isKindOfClass:[UITabBar class]])
		{
			[sheet showFromTabBar:(UITabBar *)parentView];
		}
		else if ([parentView isKindOfClass:[UIToolbar class]])
		{
			[sheet showFromToolbar:(UIToolbar *)parentView];
		}
		else
		{
			[sheet showInView:parentView];
		}
		[sheet release];
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rowTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *kPSSimpleCellIdentifier = @"PSSimpleCellIdentifier";
    static NSString *kPSTitleValueTableCellID = @"PSTitleValueTableCellID";
    UITableViewCell *cell = nil;

	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutApplicationRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSSimpleCellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPSSimpleCellIdentifier] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:applicationNameFontSize];
			cell.textLabel.text = appName;
			cell.imageView.image = appIcon;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		}
		case PSAboutVersionRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Version", @"Version");
			cell.detailTextLabel.text = appVersion;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutCopyrightRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = NSLocalizedString(@"Copyright", @"Copyright");
			cell.detailTextLabel.text = copyright;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		}
		case PSAboutCreditsRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Credits", @"Credits");
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutWebsiteRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Website", @"Website");
			cell.detailTextLabel.text = websiteURL;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutFeedbackEmailRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Email", @"Email");
			cell.detailTextLabel.text = email;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutRecommendEmailRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Send To Friend", @"Send To Friend");
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
	}
    return cell;
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"buttonIndex=%d: (%@)", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
	// Deselect table row.
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"buttonIndex=%d: (%@)", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
	NSURL *url = nil;

	switch (actionSheet.tag)
	{
		case kOpenWebsiteURLTagValue:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:websiteURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", websiteURL]];
					if (url)
					{
						PSLogDebug(@"Opening URL: %@", [url description]);
						[[UIApplication sharedApplication] openURL:url];
					}
				}
			}
			break;
		}
		case kOpenReleaseNotesURLTagValue:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:releaseNotesURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", releaseNotesURL]];
					if (url)
					{
						PSLogDebug(@"Opening URL: %@", [url description]);
						[[UIApplication sharedApplication] openURL:url];
					}
				}
			}
			break;
		}
	}
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (error)
	{
		PSLogError(@"Error sending email: %@", [error localizedDescription]);
	}

	// Dismiss mail interface.
	[self dismissModalViewControllerAnimated:YES];
}

@end

