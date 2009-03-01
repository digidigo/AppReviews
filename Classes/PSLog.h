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

#define PSLogDebug(...)		NSLog(@"[Thread %p] DEBUG: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLog(...)			NSLog(@"[Thread %p] INFO: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogInfo(...)		NSLog(@"[Thread %p] INFO: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])

#else

#undef PSLogDebug
#undef PSLog
#undef PSLogInfo
#define PSLogDebug(...) do {} while(0)
#define PSLog(...) do {} while(0)
#define PSLogInfo(...) do {} while(0)

#endif


// If using PSLogReporter then enable these as well.
#ifdef PS_USE_LOG_REPORTER

#undef PSLog
#undef PSLogInfo
#define PSLog(...)			NSLog(@"[Thread %p] INFO: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogInfo(...)		NSLog(@"[Thread %p] INFO: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])

#endif


// We always want these enabled.
#define PSLogWarning(...)				NSLog(@"[Thread %p] WARNING: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogError(...)					NSLog(@"[Thread %p] ERROR: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogRelease(...)				NSLog(@"[Thread %p] INFO: %s %@", [NSThread currentThread], __func__, [NSString stringWithFormat:__VA_ARGS__])
#define PSLogIntervalSince(msg,since)	NSLog(@"[Thread %p] TIMING: %@ took %fs", [NSThread currentThread], (msg), [[NSDate date] timeIntervalSinceDate:(since)])
#define PSLogElapsedTime(msg,elapsed)	NSLog(@"[Thread %p] TIMING: %@ took %fs", [NSThread currentThread], (msg), (elapsed))
