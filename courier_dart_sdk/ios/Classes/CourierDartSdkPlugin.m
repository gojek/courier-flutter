#import "CourierDartSdkPlugin.h"
#if __has_include(<courier_dart_sdk/courier_dart_sdk-Swift.h>)
#import <courier_dart_sdk/courier_dart_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "courier_dart_sdk-Swift.h"
#endif

@implementation CourierDartSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCourierDartSdkPlugin registerWithRegistrar:registrar];
}
@end
