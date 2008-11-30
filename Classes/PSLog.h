//
//  PSLog.h
//  PSCommon
//
//  Created by Charles Gamble on 21/10/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


// If we're not in a debug build, remove the PSLog statements. This
// makes calls to PSLog "compile out" of Release builds
#ifdef DEBUG
#define PSLogDebug(...)		NSLog(@"DEBUG: %s %@", __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLog(...)			NSLog(@"INFO: %s %@", __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogInfo(...)		NSLog(@"INFO: %s %@", __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogWarning(...)	NSLog(@"WARNING: %s %@", __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogError(...)		NSLog(@"ERROR: %s %@", __func__, [NSString stringWithFormat:__VA_ARGS__])
#else
#undef PSLogDebug
#undef PSLog
#undef PSLogInfo
#undef PSLogWarning
#undef PSLogError
#define PSLogDebug(...) do {} while(0)
#define PSLog(...) do {} while(0)
#define PSLogInfo(...) do {} while(0)
#define PSLogWarning(...) do {} while(0)
#define PSLogError(...) do {} while(0)
#endif
