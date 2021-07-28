#import "MotionphotoPlugin.h"
#if __has_include(<motionphoto/motionphoto-Swift.h>)
#import <motionphoto/motionphoto-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "motionphoto-Swift.h"
#endif

@implementation MotionphotoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMotionphotoPlugin registerWithRegistrar:registrar];
}
@end
