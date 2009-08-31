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
@property (nonatomic, assign) id returnTarget;

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
