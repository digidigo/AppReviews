//
//  PSProgressHandler.h
//  PSCommon
//
//  Created by Charles Gamble on 10/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSProgressHandler

- (void) progressBeginWithMessage:(NSString *)message;
- (void) progressEnd;
- (void) progressUpdateMessage:(NSString *)message;
- (void) progressUpdate:(NSNumber *)progress;

@end
