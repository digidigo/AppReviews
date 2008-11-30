//
//  PSAboutViewController.m
//  PSCommon
//
//  Created by Charles Gamble on 18/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSAboutViewController.h"
#import "PSTitleValueCell.h"
#import "PSLog.h"


#define OPEN_WEBSITE_URL		1
#define OPEN_RELEASE_NOTES_URL	2
#define OPEN_EMAIL				3


typedef enum
{
	PSAboutApplicationRow,
	PSAboutVersionRow,
	PSAboutCopyrightRow,
	PSAboutWebsiteRow,
	PSAboutEmailRow
} PSAboutRow;


@interface PSAboutViewController (Private)

- (id)infoValueForKey:(NSString*)key;
- (NSString *)pathForIcon;

@end


@implementation PSAboutViewController

@synthesize applicationNameFontSize, parentViewForConfirmation;


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
		self.title = @"About";
		appName = [[self infoValueForKey:@"CFBundleDisplayName"] retain];
		appVersion = [[self infoValueForKey:@"CFBundleVersion"] retain];
		copyright = [[self infoValueForKey:@"NSHumanReadableCopyright"] retain];
		websiteURL = [[self infoValueForKey:@"PSWebsiteURL"] retain];
		releaseNotesURL = [[self infoValueForKey:@"PSReleaseNotesURL"] retain];
		email = [[self infoValueForKey:@"PSContactEmail"] retain];
		NSString *iconFilePath = [self pathForIcon];
		if (iconFilePath && [iconFilePath length] > 0)
			appIcon = [[UIImage imageWithContentsOfFile:iconFilePath] retain];
		applicationNameFontSize = 28.0;
		self.parentViewForConfirmation = parentView;
    }
    return self;
}

/**
 * Destructor.
 */
- (void)dealloc
{
	[appName release];
	[appIcon release];
	[appVersion release];
	[copyright release];
	[websiteURL release];
	[releaseNotesURL release];
	[email release];
	[parentViewForConfirmation release];
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
	CFBooleanRef prerenderedFlag = (CFBooleanRef) [[self infoValueForKey:@"UIPrerenderedIcon"] retain];
	if ((prerenderedFlag == nil) || (CFBooleanGetValue(prerenderedFlag) == false))
	{
		// App has a plain icon, look for a specific icon for the About view.
		iconFile = [[self infoValueForKey:@"PSAboutIconFile"] retain];
	}
	
	if (iconFile == nil)
	{
		// Use default app icon if nothing better found.
		iconFile = [[self infoValueForKey:@"CFBundleIconFile"] retain];
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
	switch (indexPath.row)
	{
		case PSAboutWebsiteRow:
		case PSAboutVersionRow:
		case PSAboutEmailRow:
			return indexPath;
	}
	
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == PSAboutApplicationRow)
		return 67.0;
	return 44.0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row)
	{
		case PSAboutWebsiteRow:
		case PSAboutVersionRow:
		case PSAboutEmailRow:
			return UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIActionSheet *sheet = nil;
	
	switch (indexPath.row)
	{
		case PSAboutWebsiteRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:websiteURL delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Visit Website", nil];
			sheet.tag = OPEN_WEBSITE_URL;
			break;
		}
		case PSAboutVersionRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:releaseNotesURL delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Release Notes", nil];
			sheet.tag = OPEN_RELEASE_NOTES_URL;
			break;
		}
		case PSAboutEmailRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:email delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Feedback", nil];
			sheet.tag = OPEN_EMAIL;
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
		// Hide navigation bar (UIActionSheet not truly modal, so prevents user navigating off-screen).
		[self.navigationController setNavigationBarHidden:YES animated:YES];

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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *SimpleCellIdentifier = @"SimpleCell";
    static NSString *TitleValueCellIdentifier = @"TitleValueCell";
    UITableViewCell *cell = nil;
	
	switch (indexPath.row)
	{
		case PSAboutApplicationRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:SimpleCellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:SimpleCellIdentifier] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.font = [UIFont boldSystemFontOfSize:applicationNameFontSize];
			cell.text = appName;
			cell.image = appIcon;
			break;
		}
		case PSAboutVersionRow:
		{
			// Obtain the cell.
			PSTitleValueCell *tvCell = (PSTitleValueCell *) [tableView dequeueReusableCellWithIdentifier:TitleValueCellIdentifier];
			if (tvCell == nil)
			{
				tvCell = [[[PSTitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleValueCellIdentifier] autorelease];
			}
			// Configure the cell.
			tvCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			tvCell.titleWidth = 80;
			tvCell.titleLabel.text = @"Version";
			tvCell.valueLabel.text = appVersion;
			cell = tvCell;
			break;
		}
		case PSAboutCopyrightRow:
		{
			// Obtain the cell.
			PSTitleValueCell *tvCell = (PSTitleValueCell *) [tableView dequeueReusableCellWithIdentifier:TitleValueCellIdentifier];
			if (tvCell == nil)
			{
				tvCell = [[[PSTitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleValueCellIdentifier] autorelease];
			}
			// Configure the cell.
			tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
			tvCell.titleWidth = 80;
			tvCell.titleLabel.text = @"Copyright";
			tvCell.valueLabel.text = copyright;
			cell = tvCell;
			break;
		}
		case PSAboutWebsiteRow:
		{
			// Obtain the cell.
			PSTitleValueCell *tvCell = (PSTitleValueCell *) [tableView dequeueReusableCellWithIdentifier:TitleValueCellIdentifier];
			if (tvCell == nil)
			{
				tvCell = [[[PSTitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleValueCellIdentifier] autorelease];
			}
			// Configure the cell.
			tvCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			tvCell.titleWidth = 80;
			tvCell.titleLabel.text = @"Website";
			tvCell.valueLabel.text = websiteURL;
			cell = tvCell;
			break;
		}
		case PSAboutEmailRow:
		{
			// Obtain the cell.
			PSTitleValueCell *tvCell = (PSTitleValueCell *) [tableView dequeueReusableCellWithIdentifier:TitleValueCellIdentifier];
			if (tvCell == nil)
			{
				tvCell = [[[PSTitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleValueCellIdentifier] autorelease];
			}
			// Configure the cell.
			tvCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			tvCell.titleWidth = 50;
			tvCell.titleLabel.text = @"Email";
			tvCell.valueLabel.text = email;
			cell = tvCell;
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

	// Restore navigation bar.
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"buttonIndex=%d: (%@)", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
	NSURL *url = nil;
	
	switch (actionSheet.tag)
	{
		case OPEN_WEBSITE_URL:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:websiteURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", websiteURL]];
				}
			}
			break;
		}
		case OPEN_RELEASE_NOTES_URL:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:releaseNotesURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", releaseNotesURL]];
				}
			}
			break;
		}
		case OPEN_EMAIL:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				NSString *emailURL = [NSString stringWithFormat:@"mailto:%@?subject=%@%%20Feedback", email, [appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				url = [NSURL URLWithString:emailURL];
			}
			break;
		}
	}
	
	if (url)
	{
		PSLogDebug(@"Opening URL: %@", [url description]);
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end

