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
