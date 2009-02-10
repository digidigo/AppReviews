//
//  PSCountView.h
//  PSCommon
//
//  Created by Charles Gamble on 15/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Subclass of UIView which displays a positive count value in a lozenge.
 */
@interface PSCountView : UIView
{
	NSUInteger count;
	CGFloat lozengeRed;
	CGFloat lozengeGreen;
	CGFloat lozengeBlue;
	CGFloat lozengeAlpha;
	CGFloat countRed;
	CGFloat countGreen;
	CGFloat countBlue;
	CGFloat countAlpha;
	CGFloat fontSize;
}

/**
 * The count value to be displayed.
 */
@property (nonatomic, assign) NSUInteger count;

/**
 * The font size to be used.
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 * Calculates the bounds of the lozenge for a specified count and font, which allows
 * a parent view to perform sizing, layout, etc.
 *
 * @param theCount		The count value.
 * @param theFontSize	The font size.
 * @return CGRect containing the bounds required.
 */
+ (CGRect)boundsForCount:(NSUInteger)theCount usingFontSize:(CGFloat)theFontSize;

/**
 * Sets the color of the lozenge.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
- (void)setLozengeRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

/**
 * Sets the color of the lozenge.
 *
 * @param inColor	UIColor for the lozenge.
 */
- (void)setLozengeColor:(UIColor *)inColor;

/**
 * Sets the color of the count.
 *
 * @param red	Red value (0.0 - 1.0)
 * @param green	Green value (0.0 - 1.0)
 * @param blue	Blue value (0.0 - 1.0)
 * @param alpha	Alpha value (0.0 - 1.0)
 */
- (void)setCountRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

/**
 * Sets the color of the count.
 *
 * @param inColor	UIColor for the count.
 */
- (void)setCountColor:(UIColor *)inColor;

@end
