#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
static id readAX(AXUIElementRef item, CFStringRef key) {
  CFTypeRef value = NULL;
  AXError error = AXUIElementCopyAttributeValue(item, key, &value);
  return error == kAXErrorSuccess ? CFBridgingRelease(value) : @{ @"error":@(error) };
}
int main(void) {
  @autoreleasepool {
    AXUIElementRef system = AXUIElementCreateSystemWide();
    id focused = readAX(system, kAXFocusedUIElementAttribute);
    id app = readAX(system, kAXFocusedApplicationAttribute);
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"trusted"] = @(AXIsProcessTrusted());
    result[@"workspaceFront"] = NSWorkspace.sharedWorkspace.frontmostApplication.localizedName ?: @"";
    for (NSString *label in @[@"app", @"element"]) {
      id object = [label isEqual:@"app"] ? app : focused;
      if (CFGetTypeID((__bridge CFTypeRef)object) != AXUIElementGetTypeID()) { result[label] = object; continue; }
      AXUIElementRef element = (__bridge AXUIElementRef)object;
      pid_t pid = 0; AXUIElementGetPid(element, &pid);
      NSMutableDictionary *entry = [@{ @"pid":@(pid), @"name":[NSRunningApplication runningApplicationWithProcessIdentifier:pid].localizedName ?: @"" } mutableCopy];
      entry[@"role"] = readAX(element, kAXRoleAttribute);
      entry[@"focused"] = readAX(element, kAXFocusedAttribute);
      if ([label isEqual:@"app"]) {
        id window = readAX(element, kAXFocusedWindowAttribute);
        if (CFGetTypeID((__bridge CFTypeRef)window) == AXUIElementGetTypeID()) {
          entry[@"windowTitle"] = readAX((__bridge AXUIElementRef)window, kAXTitleAttribute);
          entry[@"windowFocused"] = readAX((__bridge AXUIElementRef)window, kAXFocusedAttribute);
        } else entry[@"window"] = window;
      } else entry[@"value"] = readAX(element, kAXValueAttribute);
      result[label] = entry;
    }
    puts([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding].UTF8String);
    CFRelease(system);
  }
}
