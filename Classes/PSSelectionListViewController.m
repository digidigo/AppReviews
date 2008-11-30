//
//  PSSelectionListViewController.m
//  EventHorizon
//
//  Created by Charles Gamble on 20/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import "PSSelectionListViewController.h"


@interface PSSelectionListViewController (Private)

- (BOOL)isValid;

@end


@implementation PSSelectionListViewController

@synthesize cancelButton, saveButton, allowMultipleSelections, minimumRequiredSelections, maximumRequiredSelections, listTitle, listPrompt, initialScrollPosition, returnTarget, returnSelector;

- (id)initWithStyle:(UITableViewStyle)style
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style])
	{
		self.cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton:)] autorelease];
		self.saveButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton:)] autorelease];
		self.navigationItem.hidesBackButton = YES;
		self.navigationItem.leftBarButtonItem = self.cancelButton;
		self.navigationItem.rightBarButtonItem = self.saveButton;

		self.allowMultipleSelections = NO;
		self.minimumRequiredSelections = 1;
		self.maximumRequiredSelections = INT32_MAX;
		self.listTitle = @"Title";
		self.listPrompt = nil;
		self.initialScrollPosition = nil;
		listLabels = [[NSArray array] retain];
		listValues = [[NSArray array] retain];
		listSelections = [[NSArray array] retain];
    }
    return self;
}

- (void)dealloc
{
	[cancelButton release];
	[saveButton release];
	[listTitle release];
	[listPrompt release];
	[initialScrollPosition release];
	[listLabels release];
	[listValues release];
	[listSelections release];
    [super dealloc];
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

- (void)setListLabels:(NSArray *)labels values:(NSArray *)values selections:(NSArray *)selections
{
	if (labels && values && ([labels count] == [values count]) &&
		((selections == nil) || (selections && ([selections count] == [labels count]))))
	{
		[labels retain];
		[listLabels release];
		listLabels = [labels copy];
		
		[values retain];
		[listValues release];
		listValues = [values copy];
		
		if (selections)
		{
			[selections retain];
			[listSelections release];
			listSelections = [[NSMutableArray arrayWithArray:selections] retain];
		}
		else
		{
			[listSelections release];
			listSelections = [[NSMutableArray array] retain];
			// Initialise items to unselected.
			for (int i = 0; i < [labels count]; i++)
			{
				[listSelections addObject:[NSNumber numberWithBool:NO]];
			}
		}
	}
	
	// Refresh table data.
	[self.tableView reloadData];
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
				thisCell.textColor = [UIColor blackColor];
				[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];			
			}
			else
			{
				// This row *not* already selected - toggle it.
				thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
				thisCell.textColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
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
				oldCell.textColor = [UIColor blackColor];
				[listSelections replaceObjectAtIndex:oldRow withObject:[NSNumber numberWithBool:NO]];			
				
				// Select this row.
				UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
				thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
				thisCell.textColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
				[listSelections replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
			}
		}
	}
	else
	{
		// List currently has no selected items - Select this row.
		UITableViewCell *thisCell = [self.tableView cellForRowAtIndexPath:indexPath];
		thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
		thisCell.textColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
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
    return [listLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	cell.text = [listLabels objectAtIndex:indexPath.row];
	NSNumber *selected = (NSNumber *) [listSelections objectAtIndex:indexPath.row];
	if ([selected boolValue])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textColor = [UIColor blackColor];
	}
    return cell;
}

@end

