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

#import "PSSelectionListViewController.h"
#import "PSLog.h"
#import "UIColor+MoreColors.h"


@interface PSSelectionListViewController ()

@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *saveButton;

- (BOOL)isValid;

@end


@implementation PSSelectionListViewController

@synthesize cancelButton, saveButton, allowMultipleSelections, minimumRequiredSelections, maximumRequiredSelections, listTitle, listPrompt, initialScrollPosition, returnTarget, returnSelector;

/**
 * Designated initializer.
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.returnTarget = nil;
		self.allowMultipleSelections = NO;
		self.minimumRequiredSelections = 1;
		self.maximumRequiredSelections = INT32_MAX;
		self.listTitle = @"Title";
		self.listPrompt = nil;
		self.initialScrollPosition = nil;
		listLabels = [[NSArray array] retain];
		listImages = nil;
		listValues = [[NSArray array] retain];
		listSelections = [[NSArray array] retain];
    }
    return self;
}

/**
 * Destructor.
 */
- (void)dealloc
{
	PSLogDebug(@"");
	[cancelButton release];
	[saveButton release];
	[listTitle release];
	[listPrompt release];
	[initialScrollPosition release];
	[listLabels release];
	[listImages release];
	[listValues release];
	[listSelections release];
    [super dealloc];
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	self.cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton:)] autorelease];
	self.saveButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton:)] autorelease];
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Release IBOutlets and items which can be recreated in viewDidLoad.
	self.cancelButton = nil;
	self.saveButton = nil;
}

/**
 * Sets the values, labels, images and selections for the list.
 *
 * @param labels		Array of labels.
 * @param images		Array of images.
 * @param values		Array of values.
 * @param selections	Array of selection flags.
 */
- (void)setListLabels:(NSArray *)labels images:(NSArray *)images values:(NSArray *)values selections:(NSArray *)selections
{
	// values: mandatory
	// labels: optional, can be nil.
	// images: optional, can be nil.
	// At least one of either labels or images must not be nil.
	// selections: optional, can be nil.
	if (values &&
		((labels == nil) || (labels && ([labels count] == [values count]))) &&
		((images == nil) || (images && ([images count] == [values count]))) &&
		(labels || images) &&
		((selections == nil) || (selections && ([selections count] == [values count]))))
	{
		[[values retain] autorelease];
		[listValues release];
		listValues = [values copy];

		[[labels retain] autorelease];
		[listLabels release];
		if (labels)
			listLabels = [labels copy];
		else
			listLabels = nil;

		[[images retain] autorelease];
		[listImages release];
		if (images)
			listImages = [images copy];
		else
			listImages = nil;

		if (selections)
		{
			[[selections retain] autorelease];
			[listSelections release];
			listSelections = [[NSMutableArray arrayWithArray:selections] retain];
		}
		else
		{
			[listSelections release];
			listSelections = [[NSMutableArray array] retain];
			// Initialise items to unselected.
			for (int i = 0; i < [values count]; i++)
			{
				[listSelections addObject:[NSNumber numberWithBool:NO]];
			}
		}
	}

	// Refresh table data.
	[self.tableView reloadData];
}

/**
 * Gets the count of selected items.
 */
- (NSUInteger)selectionCount
{
	NSUInteger result = 0;

	for (NSNumber *selected in listSelections)
	{
		if ([selected boolValue])
			result++;
	}

	return result;
}

/**
 * Gets the selected values.
 */
- (NSArray *)selectedValues
{
	NSMutableArray *result = [NSMutableArray array];
	for (int i = 0; i < [listSelections count]; i++)
	{
		NSNumber *selected = (NSNumber *) [listSelections objectAtIndex:i];
		if (selected && [selected boolValue])
		{
			// Found a selected index value.
			[result addObject:[listValues objectAtIndex:i]];
		}
	}
	return result;
}

- (BOOL)isValid
{
	NSUInteger numSelections = [self selectionCount];

	// Check minimum number of selections have been made.
	if (numSelections < minimumRequiredSelections)
		return NO;
	// Check maximum number of selections has not been breached.
	if (numSelections > maximumRequiredSelections)
		return NO;

	if (!allowMultipleSelections && (numSelections > 1))
		return NO;

	// All looks OK.
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.navigationItem.prompt = self.listPrompt;
	self.navigationItem.title = self.listTitle;

	// Enable/disable Save button as appropriate.
	if ([self isValid])
		saveButton.enabled = YES;
	else
		saveButton.enabled = NO;

	[self.tableView reloadData];

	// Auto-scroll to show required row.
	if (initialScrollPosition)
	{
		[self.tableView scrollToRowAtIndexPath:initialScrollPosition atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)cancelButton:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButton:(id)sender
{
	if ([self isValid])
	{
		// Return list values/selections.
		if (returnTarget)
		{
			[returnTarget performSelector:returnSelector withObject:[self selectedValues]];
		}
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"List selection invalid!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self selectionCount] > 0)
	{
		// List already has at least 1 item selected.
		if (allowMultipleSelections)
		{
			// Multiple-selection mode.

			// Toggle selection status of this row.
			UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
			NSNumber *thisRow = (NSNumber *) [listSelections objectAtIndex:indexPath.row];
			if ([thisRow boolValue])
			{
				// This row *is* already selected - toggle it.
				thisCell.accessoryType = UITableViewCellAccessoryNone;
				thisCell.textLabel.textColor = [UIColor blackColor];
				[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
			}
			else
			{
				// This row *not* already selected - toggle it.
				thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
				thisCell.textLabel.textColor = [UIColor tableCellTextBlue];
				[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
			}
		}
		else
		{
			// Single-selection mode (radio-buttons).
			NSNumber *thisRow = (NSNumber *) [listSelections objectAtIndex:indexPath.row];
			if (![thisRow boolValue])
			{
				// This row *not* already selected.

				// Deselect old row.
				NSUInteger oldRow = [listSelections indexOfObject:[NSNumber numberWithBool:YES]];
				NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldRow inSection:0];
				UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
				oldCell.accessoryType = UITableViewCellAccessoryNone;
				oldCell.textLabel.textColor = [UIColor blackColor];
				[listSelections replaceObjectAtIndex:oldRow withObject:[NSNumber numberWithBool:NO]];

				// Select this row.
				UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
				thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
				thisCell.textLabel.textColor = [UIColor tableCellTextBlue];
				[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
			}
		}
	}
	else
	{
		// List currently has no selected items - Select this row.
		UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
		thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
		thisCell.textLabel.textColor = [UIColor tableCellTextBlue];
		[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
	}

	// Enable/disable Save button as appropriate.
	if ([self isValid])
		saveButton.enabled = YES;
	else
		saveButton.enabled = NO;

	// Deselect row.
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	if (listLabels)
		cell.textLabel.text = [listLabels objectAtIndex:indexPath.row];
	else
		cell.textLabel.text = nil;

	if (listImages)
		cell.imageView.image = [listImages objectAtIndex:indexPath.row];
	else
		cell.imageView.image = nil;

	NSNumber *selected = (NSNumber *) [listSelections objectAtIndex:indexPath.row];
	if ([selected boolValue])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor tableCellTextBlue];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}
    return cell;
}

@end

