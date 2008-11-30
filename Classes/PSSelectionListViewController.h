//
//  PSSelectionListViewController.h
//  EventHorizon
//
//  Created by Charles Gamble on 20/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


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
	NSArray *listValues;
	NSMutableArray *listSelections;
	NSIndexPath *initialScrollPosition;
	id returnTarget;
	SEL returnSelector;
}

@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, assign) BOOL allowMultipleSelections;
@property (nonatomic, assign) NSUInteger minimumRequiredSelections;
@property (nonatomic, assign) NSUInteger maximumRequiredSelections;
@property (nonatomic, copy) NSString *listTitle;
@property (nonatomic, copy) NSString *listPrompt;
@property (nonatomic, retain) NSIndexPath *initialScrollPosition;
@property (nonatomic, retain) id returnTarget;
@property (nonatomic, assign) SEL returnSelector;

- (NSUInteger)selectionCount;
- (NSArray *)selectedValues;
- (void)setListLabels:(NSArray *)labels values:(NSArray *)values selections:(NSArray *)selections;

@end
