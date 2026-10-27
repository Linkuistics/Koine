#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
// Use a fresh process per read: time-varying properties persist until a main-run-loop turn.
// macOS 27 SDK NSRunningApplication.h; https://developer.apple.com/documentation/appkit/nsrunningapplication
int main(void) {
  @autoreleasepool {
    NSRunningApplication *front = NSWorkspace.sharedWorkspace.frontmostApplication;
    NSMutableArray *apps = [NSMutableArray array];
    for (NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications) {
      if ([app.localizedName isEqual:@"Koine"] || [app.localizedName isEqual:@"TextEdit"]) {
        [apps addObject:@{ @"name":app.localizedName, @"pid":@(app.processIdentifier), @"active":@(app.active), @"policy":@(app.activationPolicy) }];
      }
    }
    NSArray *all = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
    NSMutableArray *windows = [NSMutableArray array];
    for (NSDictionary *w in all) {
      if ([w[(id)kCGWindowLayer] intValue] == 0) [windows addObject:@{ @"app":w[(id)kCGWindowOwnerName] ?: @"", @"pid":w[(id)kCGWindowOwnerPID] ?: @0, @"number":w[(id)kCGWindowNumber] ?: @0 }];
    }
    NSDictionary *row = @{ @"time":@([NSDate date].timeIntervalSince1970), @"front":front.localizedName ?: @"", @"pid":@(front.processIdentifier), @"apps":apps, @"windows":windows };
    puts([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:row options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding].UTF8String);
  }
}
