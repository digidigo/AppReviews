//
//	Copyright (c) 2008-2009, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
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
//	* Neither the name of AppReviews nor the names of its contributors may be used
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
