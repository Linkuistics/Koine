#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
int main(void) {
  @autoreleasepool {
    for (int i = 0; i < 600; i++) {
      NSRunningApplication *app = NSWorkspace.sharedWorkspace.frontmostApplication;
      NSArray *all = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
      NSMutableArray *windows = [NSMutableArray array];
      for (NSDictionary *w in all) {
        if ([w[(id)kCGWindowLayer] intValue] == 0) [windows addObject:@{ @"app":w[(id)kCGWindowOwnerName] ?: @"", @"pid":w[(id)kCGWindowOwnerPID] ?: @0, @"number":w[(id)kCGWindowNumber] ?: @0 }];
      }
      NSDictionary *row = @{ @"time":@([NSDate date].timeIntervalSince1970), @"front":app.localizedName ?: @"", @"pid":@(app.processIdentifier), @"windows":windows };
      puts([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:row options:0 error:nil] encoding:NSUTF8StringEncoding].UTF8String);
      fflush(stdout);
      usleep(100000);
    }
  }
}
