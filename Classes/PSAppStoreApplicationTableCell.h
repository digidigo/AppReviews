//
//  PSAppStoreApplicationTableCell.h
//  EventHorizon
//
//  Created by Charles Gamble on 16/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PSAppStoreApplicationTableCell : UITableViewCell
{
	UILabel *nameLabel;
	UILabel *companyLabel;
}

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *companyLabel;

@end
