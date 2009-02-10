//
//  PSImageView.h
//  PSCommon
//
//  Created by Charles Gamble on 21/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Subclass of UIView to display a UIImage centered within the view.
 */
@interface PSImageView : UIView
{
	UIImage *image;
}

/**
 * The UIImage to be displayed.
 */
@property (nonatomic, retain) UIImage *image;

@end
