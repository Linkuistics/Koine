#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/pwr_mgt/IOPM.h>
#include <stdio.h>
#include <unistd.h>
@interface ProbeDelegate : NSObject <NSApplicationDelegate>
@property(strong) NSWindow *window;
@end
@implementation ProbeDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)note {
    ProcessSerialNumber psn = {0, 0};
    OSStatus s = GetCurrentProcess(&psn);
    io_registry_entry_t root = IORegistryEntryFromPath(kIOMainPortDefault, "IOPower:/IOPowerConnection/IOPMrootDomain");
    CFTypeRef value = root ? IORegistryEntryCreateCFProperty(root, CFSTR(kIOPMBootSessionUUIDKey), kCFAllocatorDefault, 0) : NULL;
    char boot[128] = {0};
    if (value && CFGetTypeID(value) == CFStringGetTypeID()) CFStringGetCString(value, boot, sizeof boot, kCFStringEncodingUTF8);
    fprintf(stderr, "start pid=%d psn=%08x%08x status=%d boot=%s root=%u\n", getpid(), (unsigned)psn.highLongOfPSN, (unsigned)psn.lowLongOfPSN, s, boot, root);
    if (value) CFRelease(value);
    if (root) IOObjectRelease(root);
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 400, 180) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
    self.window.title = @"K51 automatic termination probe";
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activate];
    [self performSelector:@selector(becomeIdle) withObject:nil afterDelay:20.0];
}
- (void)becomeIdle {
    [self.window close];
    [NSApp hide:nil];
    fprintf(stderr, "idle pid=%d\n", getpid());
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app { return NO; }
- (void)applicationWillTerminate:(NSNotification *)note { fprintf(stderr, "willTerminate pid=%d\n", getpid()); }
@end
int main(int argc, const char **argv) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        ProbeDelegate *delegate = [ProbeDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app run];
    }
    return 0;
}
