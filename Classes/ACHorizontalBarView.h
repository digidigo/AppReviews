//
//  ACHorizontalBarView.h
//  PSCommon
//
//  Created by Charles Gamble on 23/06/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Subclass of UIView which displays a filled bar representing a value between 0.0 and 1.0.
 */
@interface ACHorizontalBarView : UIView
{
	double barValue;
	CGFloat barRed;
	CGFloat barGreen;
	CGFloat barBlue;
	CGFloat barAlpha;
}

/**
 * The bar value to be displayed.
 */
@property (nonatomic, assign) double barValue;

/**
 * Sets the color of the bar.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
- (void)setBarRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

/**
 * Sets the color of the bar.
 *
 * @param inColor	UIColor for the lozenge.
 */
- (void)setBarColor:(UIColor *)inColor;

@end
