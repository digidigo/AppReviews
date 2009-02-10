//
//  PSSelectionListViewController.h
//  PSCommon
//
//  Created by Charles Gamble on 20/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * A generic selection list view that allows a list of items to be shown
 * so that the user can select one (or more) items from the list.
 * Can show text & image for each item, and each item must have a specified
 * value. Supports single and multiple selections.
 */
@interface PSSelectionListViewController : UITableViewController
{
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *saveButton;
	BOOL	allowMultipleSelections;
	NSUInteger minimumRequiredSelections;
	NSUInteger maximumRequiredSelections;
	NSString *listTitle;
	NSString *listPrompt;
	NSArray *listLabels;
	NSArray *listImages;
	NSArray *listValues;
	NSMutableArray *listSelections;
	NSIndexPath *initialScrollPosition;
	id returnTarget;
	SEL returnSelector;
}

/**
 * Flag indicating if multiple selections are allowed.
 */
@property (nonatomic, assign) BOOL allowMultipleSelections;

/**
 * Minimum number of selections required.
 */
@property (nonatomic, assign) NSUInteger minimumRequiredSelections;

/**
 * Maximum number of selections required.
 */
@property (nonatomic, assign) NSUInteger maximumRequiredSelections;

/**
 * Title.
 */
@property (nonatomic, copy) NSString *listTitle;

/**
 * Prompt.
 */
@property (nonatomic, copy) NSString *listPrompt;

/**
 * Allows list to auto-scroll to an initial position.
 */
@property (nonatomic, retain) NSIndexPath *initialScrollPosition;

/**
 * Target object that will be notified of final selection.
 */
@property (nonatomic, retain) id returnTarget;

/**
 * Selector to be called on target object when notifying of final selection.
 */
@property (nonatomic, assign) SEL returnSelector;

/**
 * Designated initializer.
 */
- (id)initWithStyle:(UITableViewStyle)style;

/**
 * Destructor.
 */
- (void)dealloc;

/**
 * Sets the values, labels, images and selections for the list.
 *
 * @param labels		Array of labels.
 * @param images		Array of images.
 * @param values		Array of values.
 * @param selections	Array of selection flags.
 */
- (void)setListLabels:(NSArray *)labels images:(NSArray *)images values:(NSArray *)values selections:(NSArray *)selections;

/**
 * Gets the count of selected items.
 */
- (NSUInteger)selectionCount;

/**
 * Gets the selected values.
 */
- (NSArray *)selectedValues;

@end
