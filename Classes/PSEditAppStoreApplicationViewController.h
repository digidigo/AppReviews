//
//  PSEditAppStoreApplicationViewController.h
//  AppCritics
//
//  Created by Charles Gamble on 15/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PSAppStoreApplication;
@class PSSelectionListViewController;


@interface PSEditAppStoreApplicationViewController : UIViewController
{
	IBOutlet UITextField *appId;
	IBOutlet UILabel *label;
	IBOutlet UIButton *defaultStoreButton;
	IBOutlet UIBarButtonItem *saveButton;
	NSString *defaultStore;
	PSAppStoreApplication *app;
	PSSelectionListViewController *selectionListViewController;
}

@property (nonatomic, retain) UITextField *appId;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *defaultStoreButton;
@property (nonatomic, retain) NSString *defaultStore;
@property (nonatomic, retain) PSAppStoreApplication *app;
@property (nonatomic, retain) PSSelectionListViewController *selectionListViewController;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)chooseDefaultStore:(id)sender;
- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
