//
//  PSSynthesizeSingleton.h
//
//  Created by Matt Gallagher on 20/10/08.
//  Modified by Charles Gamble.
//
//  For more info:
//    http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
//    http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/chapter_3_section_10.html
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
static classname *shared##classname = nil; \
 \
+ (classname *)sharedInstance \
{ \
	if (shared##classname == nil) \
	{ \
		@synchronized(self) \
		{ \
			if (shared##classname == nil) \
			{ \
				[[self alloc] init]; \
			} \
		} \
	} \
	 \
	return shared##classname; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	if (shared##classname == nil) \
	{ \
		@synchronized(self) \
		{ \
			if (shared##classname == nil) \
			{ \
				shared##classname = [super allocWithZone:zone]; \
				return shared##classname; \
			} \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
