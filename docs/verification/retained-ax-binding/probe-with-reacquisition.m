// Diagnostic only. Build on the host; execute only in a disposable VM.
// Deliberately recycles one of this program's own child PIDs, with at most
// one child at a time. Does not target or terminate unrelated processes.
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#include <mach/mach.h>
#include <sys/wait.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>

static void emit(NSDictionary *value) {
    NSData *json = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
    fwrite(json.bytes, 1, json.length, stdout);
    fputc('\n', stdout);
    fflush(stdout);
}

static id attribute(AXUIElementRef element, CFStringRef name, AXError *error) {
    CFTypeRef value = NULL;
    *error = AXUIElementCopyAttributeValue(element, name, &value);
    return CFBridgingRelease(value);
}

static NSDictionary *describe(AXUIElementRef element) {
    if (!element) return @{ @"missing": @YES };
    AXError error;
    id title = attribute(element, kAXTitleAttribute, &error);
    AXError roleError;
    id role = attribute(element, kAXRoleAttribute, &roleError);
    pid_t pid = -1;
    AXError pidError = AXUIElementGetPid(element, &pid);
    return @{ @"titleError": @(error), @"title": title ?: NSNull.null,
              @"roleError": @(roleError), @"role": role ?: NSNull.null,
              @"pidError": @(pidError), @"pid": @(pid) };
}

static AXUIElementRef windowFor(AXUIElementRef application) {
    for (int i = 0; i < 100; i++) {
        AXError error;
        NSArray *windows = attribute(application, kAXWindowsAttribute, &error);
        if (error == kAXErrorSuccess && [windows isKindOfClass:NSArray.class] && windows.count) {
            return (AXUIElementRef)CFRetain((__bridge CFTypeRef)windows.firstObject);
        }
        usleep(100000);
    }
    return NULL;
}

static void reap(pid_t pid) {
    int status;
    while (waitpid(pid, &status, 0) < 0) {
        if (errno != EINTR) { perror("waitpid"); exit(4); }
    }
}

static int target(const char *label) {
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(100, 100, 480, 280)
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                   NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
        backing:NSBackingStoreBuffered defer:NO];
    window.title = [NSString stringWithUTF8String:label];
    NSTextField *text = [NSTextField labelWithString:window.title];
    text.frame = NSMakeRect(20, 100, 420, 30);
    [window.contentView addSubview:text];
    [window makeKeyAndOrderFront:nil];
    emit(@{ @"phase": @"target-ready", @"pid": @(getpid()), @"label": window.title });
    [NSApp run];
    return 0;
}

static void witness(const char *executable, pid_t pid, NSString *phase) {
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:executable]];
    task.arguments = @[@"--inspect", [@(pid) stringValue], phase];
    NSError *error;
    if (![task launchAndReturnError:&error]) {
        emit(@{ @"phase": @"witness-launch-failed", @"error": error.description });
        exit(8);
    }
    [task waitUntilExit];
    if (task.terminationStatus != 0) exit(9);
}

int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc == 3 && strcmp(argv[1], "--target") == 0) return target(argv[2]);
        if (argc == 4 && strcmp(argv[1], "--inspect") == 0) {
            AXUIElementRef app = AXUIElementCreateApplication(atoi(argv[2]));
            AXUIElementSetMessagingTimeout(app, 1);
            AXUIElementRef window = windowFor(app);
            AXError error = kAXErrorInvalidUIElement;
            id minimized = window ? attribute(window, kAXMinimizedAttribute, &error) : nil;
            emit(@{ @"phase": [NSString stringWithUTF8String:argv[3]],
                    @"application": describe(app), @"window": describe(window),
                    @"minimizedError": @(error), @"minimized": minimized ?: NSNull.null });
            if (window) CFRelease(window);
            CFRelease(app);
            return window ? 0 : 10;
        }
        emit(@{ @"phase": @"trust", @"trusted": @(AXIsProcessTrusted()),
                @"os": NSProcessInfo.processInfo.operatingSystemVersionString });
        if (argc != 2 || strcmp(argv[1], "--run") != 0) return 0;
        if (!AXIsProcessTrusted()) return 2;
        char *originalArgs[] = {argv[0], "--target", "ORIGINAL PROCESS", NULL};
        char *replacementArgs[] = {argv[0], "--target", "REPLACEMENT PROCESS", NULL};
        pid_t original = fork();
        if (original == 0) { execv(argv[0], originalArgs); _exit(127); }
        if (original < 0) { perror("fork"); return 3; }
        AXUIElementRef application = AXUIElementCreateApplication(original);
        AXUIElementSetMessagingTimeout(application, 1);
        AXUIElementRef window = windowFor(application);
        if (!window) { kill(original, SIGKILL); reap(original); return 5; }
        AXError parentError;
        id parentValue = attribute(window, kAXParentAttribute, &parentError);
        AXUIElementRef parent = parentError == kAXErrorSuccess && parentValue &&
            CFGetTypeID((__bridge CFTypeRef)parentValue) == AXUIElementGetTypeID()
                ? (AXUIElementRef)CFRetain((__bridge CFTypeRef)parentValue) : NULL;
        mach_port_t heldTask = MACH_PORT_NULL;
        kern_return_t taskResult = task_name_for_pid(mach_task_self(), original, &heldTask);
        emit(@{ @"phase": @"original", @"pid": @(original),
                @"application": describe(application), @"window": describe(window),
                @"parent": describe(parent), @"parentError": @(parentError),
                @"parentEqualsApplication": @(parent && CFEqual(parent, application)),
                @"taskResult": @(taskResult), @"taskName": @(heldTask) });
        kill(original, SIGKILL);
        reap(original);
        emit(@{ @"phase": @"terminated", @"application": describe(application),
                @"window": describe(window), @"parent": describe(parent) });
        pid_t replacement = -1;
        int attempts = 0;
        // Bound the experiment. Reaching the cap is inconclusive, not a pass.
        for (; attempts < 300000; attempts++) {
            pid_t child = fork();
            if (child == 0) {
                if (getpid() == original) { execv(argv[0], replacementArgs); _exit(127); }
                _exit(0);
            }
            if (child < 0) { perror("fork"); return 3; }
            if (child == original) { replacement = child; break; }
            reap(child);
            if (attempts % 10000 == 0) emit(@{ @"phase": @"cycling", @"attempts": @(attempts) });
        }
        if (replacement < 0) { emit(@{ @"phase": @"inconclusive", @"attempts": @(attempts) }); return 6; }
        AXUIElementRef freshApplication = AXUIElementCreateApplication(replacement);
        AXUIElementSetMessagingTimeout(freshApplication, 1);
        witness(argv[0], replacement, @"witness-before");
        AXUIElementRef freshWindow = windowFor(freshApplication);
        mach_port_type_t heldType = 0;
        kern_return_t typeResult = mach_port_type(mach_task_self(), heldTask, &heldType);
        mach_port_t newTask = MACH_PORT_NULL;
        kern_return_t newTaskResult = task_name_for_pid(mach_task_self(), replacement, &newTask);
        emit(@{ @"phase": @"recycled", @"pid": @(replacement), @"attempts": @(attempts + 1),
                @"heldApplication": describe(application), @"heldWindow": describe(window),
                @"heldParent": describe(parent), @"freshWindow": describe(freshWindow),
                @"applicationEqual": @(CFEqual(application, freshApplication)),
                @"windowEqual": @(freshWindow && CFEqual(window, freshWindow)),
                @"heldTaskTypeResult": @(typeResult), @"heldTaskType": @(heldType),
                @"newTaskResult": @(newTaskResult), @"newTaskName": @(newTask) });
        AXError minimize = AXUIElementSetAttributeValue(window, kAXMinimizedAttribute, kCFBooleanTrue);
        AXError minimizedRead = kAXErrorInvalidUIElement;
        id minimized = freshWindow ? attribute(freshWindow, kAXMinimizedAttribute, &minimizedRead) : nil;
        emit(@{ @"phase": @"effect", @"heldWindowMinimizeResult": @(minimize),
                @"replacementMinimizedRead": @(minimizedRead),
                @"replacementMinimized": minimized ?: NSNull.null });
        witness(argv[0], replacement, @"witness-after");
        kill(replacement, SIGKILL);
        reap(replacement);
        if (freshWindow) CFRelease(freshWindow);
        CFRelease(freshApplication);
        if (parent) CFRelease(parent);
        CFRelease(window); CFRelease(application);
        if (heldTask != MACH_PORT_NULL) mach_port_deallocate(mach_task_self(), heldTask);
        if (newTask != MACH_PORT_NULL) mach_port_deallocate(mach_task_self(), newTask);
        return 0;
    }
}
