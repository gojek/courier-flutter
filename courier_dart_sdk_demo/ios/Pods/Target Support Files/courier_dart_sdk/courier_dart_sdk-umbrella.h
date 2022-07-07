#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CourierDartSdkPlugin.h"

FOUNDATION_EXPORT double courier_dart_sdkVersionNumber;
FOUNDATION_EXPORT const unsigned char courier_dart_sdkVersionString[];

