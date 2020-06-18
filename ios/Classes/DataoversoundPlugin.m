#import "DataoversoundPlugin.h"
#if __has_include(<dataoversound/dataoversound-Swift.h>)
#import <dataoversound/dataoversound-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dataoversound-Swift.h"
#endif

@implementation DataoversoundPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDataoversoundPlugin registerWithRegistrar:registrar];
}
@end
