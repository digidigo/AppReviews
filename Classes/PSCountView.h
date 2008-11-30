//
//  PSCountView.h
//  EventHorizon
//
//  Created by Charles Gamble on 15/09/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


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

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) CGFloat fontSize;

+ (CGRect)boundsForCount:(NSUInteger)theCount usingFontSize:(CGFloat)theFontSize;
- (void)setLozengeRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (void)setCountRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end
