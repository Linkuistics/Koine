// Private AX diagnostic only. Build on host; execute only in a disposable VM.
// The shared fixture owns controlled target creation and independent witnesses.
#define main public_probe_main
#include "probe.m"
#undef main
#include <dlfcn.h>

// These diagnostic signatures are inferred from the macOS 26.5 loaded code
// preserved in private-symbols.json, not from a supported SDK declaration.
typedef CFDataRef (*TokenCreate)(AXUIElementRef);
typedef AXUIElementRef (*FromToken)(CFDataRef);
typedef AXError (*GetData)(AXUIElementRef, CFDataRef *, uint32_t *);
typedef AXUIElementRef (*FromData)(CFDataRef, uint32_t, pid_t, pid_t);
typedef AXError (*ActualPid)(AXUIElementRef, pid_t *);

static int runPrivate(char **argv) {
    TokenCreate tokenCreate = dlsym(RTLD_DEFAULT, "_AXUIElementRemoteTokenCreate");
    FromToken fromToken = dlsym(RTLD_DEFAULT, "_AXUIElementCreateWithRemoteToken");
    GetData getData = dlsym(RTLD_DEFAULT, "_AXUIElementGetData");
    FromData fromData = dlsym(RTLD_DEFAULT, "_AXUIElementCreateWithDataAndPid");
    ActualPid actualPid = dlsym(RTLD_DEFAULT, "_AXUIElementGetActualPid");
    emit(@{@"phase": @"private-availability", @"tokenCreate": @(tokenCreate != NULL),
        @"fromToken": @(fromToken != NULL), @"getData": @(getData != NULL),
        @"fromData": @(fromData != NULL), @"actualPid": @(actualPid != NULL),
        @"trusted": @(AXIsProcessTrusted()),
        @"os": NSProcessInfo.processInfo.operatingSystemVersionString});
    if (!tokenCreate || !fromToken || !getData || !fromData || !actualPid) return 11;
    if (!AXIsProcessTrusted()) return 2;
    char *originalArgs[] = {argv[0], "--target", "ORIGINAL PROCESS", NULL};
    char *replacementArgs[] = {argv[0], "--target", "REPLACEMENT PROCESS", NULL};
    pid_t original = fork();
    if (original == 0) { execv(argv[0], originalArgs); _exit(127); }
    if (original < 0) return 3;
    AXUIElementRef app = AXUIElementCreateApplication(original);
    AXUIElementSetMessagingTimeout(app, 1);
    AXUIElementRef window = windowFor(app);
    if (!window) { kill(original, SIGKILL); reap(original); CFRelease(app); return 5; }
    CFDataRef token = tokenCreate(window);
    AXUIElementRef tokenWindow = token ? fromToken(token) : NULL;
    CFDataRef data = NULL;
    uint32_t kind = 0;
    AXError dataResult = getData(window, &data, &kind);
    AXUIElementRef dataWindow = dataResult == kAXErrorSuccess
        ? fromData(data, kind, original, 0) : NULL;
    mach_port_t heldTask = MACH_PORT_NULL;
    kern_return_t taskResult = task_name_for_pid(mach_task_self(), original, &heldTask);
    pid_t reportedPid = -1;
    AXError pidResult = tokenWindow ? actualPid(tokenWindow, &reportedPid) : kAXErrorInvalidUIElement;
    emit(@{@"phase": @"original-private", @"pid": @(original),
        @"tokenHex": token ? [(__bridge NSData *)token description] : @"missing",
        @"tokenLength": @(token ? CFDataGetLength(token) : 0),
        @"dataKind": @(kind), @"dataResult": @(dataResult),
        @"dataHex": data ? [(__bridge NSData *)data description] : @"missing",
        @"tokenWindow": describe(tokenWindow), @"dataWindow": describe(dataWindow),
        @"tokenEqualsOriginal": @(tokenWindow && CFEqual(tokenWindow, window)),
        @"dataEqualsOriginal": @(dataWindow && CFEqual(dataWindow, window)),
        @"actualPidResult": @(pidResult), @"actualPid": @(reportedPid),
        @"taskResult": @(taskResult), @"taskName": @(heldTask)});
    if (!tokenWindow || !dataWindow || !CFEqual(tokenWindow, window) || !CFEqual(dataWindow, window)
        || taskResult != KERN_SUCCESS || !MACH_PORT_VALID(heldTask)) {
        kill(original, SIGKILL); reap(original); return 12;
    }
    kill(original, SIGKILL); reap(original);
    emit(@{@"phase": @"terminated-private", @"tokenWindow": describe(tokenWindow),
        @"dataWindow": describe(dataWindow)});
    pid_t replacement = -1;
    int attempts = 0;
    for (; attempts < 300000; ++attempts) {
        pid_t child = fork();
        if (child == 0) {
            if (getpid() == original) { execv(argv[0], replacementArgs); _exit(127); }
            _exit(0);
        }
        if (child < 0) return 3;
        if (child == original) { replacement = child; break; }
        reap(child);
        if (attempts % 10000 == 0) emit(@{@"phase": @"cycling", @"attempts": @(attempts)});
    }
    if (replacement < 0) { emit(@{@"phase": @"inconclusive", @"attempts": @(attempts)}); return 6; }
    witness(argv[0], replacement, @"witness-before-private");
    mach_port_type_t heldType = 0;
    kern_return_t typeResult = mach_port_type(mach_task_self(), heldTask, &heldType);
    reportedPid = -1;
    pidResult = actualPid(tokenWindow, &reportedPid);
    emit(@{@"phase": @"recycled-private", @"pid": @(replacement), @"attempts": @(attempts + 1),
        @"tokenWindow": describe(tokenWindow), @"dataWindow": describe(dataWindow),
        @"heldTaskTypeResult": @(typeResult), @"heldTaskType": @(heldType),
        @"actualPidResult": @(pidResult), @"actualPid": @(reportedPid)});
    AXError minimize = AXUIElementSetAttributeValue(tokenWindow, kAXMinimizedAttribute, kCFBooleanTrue);
    emit(@{@"phase": @"private-token-effect", @"minimizeResult": @(minimize)});
    witness(argv[0], replacement, @"witness-after-token-minimize");
    AXError restore = AXUIElementSetAttributeValue(dataWindow, kAXMinimizedAttribute, kCFBooleanFalse);
    emit(@{@"phase": @"private-data-effect", @"restoreResult": @(restore)});
    witness(argv[0], replacement, @"witness-after-data-restore");
    kill(replacement, SIGKILL); reap(replacement);
    CFRelease(tokenWindow); CFRelease(dataWindow); CFRelease(token);
    CFRelease(window); CFRelease(app);
    mach_port_deallocate(mach_task_self(), heldTask);
    return 0;
}

int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc == 2 && strcmp(argv[1], "--run-private") == 0) return runPrivate(argv);
        return public_probe_main(argc, argv);
    }
}
