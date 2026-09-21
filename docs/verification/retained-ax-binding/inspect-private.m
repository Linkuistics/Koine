// Read our own loaded library code; no target process is inspected or modified.
// Diagnostic only; execute in a disposable TestAnyware VM.
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#include <dlfcn.h>
#include <stdint.h>

int main(void) {
    @autoreleasepool {
        NSMutableArray *items = [NSMutableArray array];
        const char *names[] = {"_AXUIElementRemoteTokenCreate",
            "_AXUIElementCreateWithRemoteToken", "_AXUIElementCreateWithDataAndPid",
            "_AXUIElementGetActualPid", "_AXUIElementGetData"};
        for (unsigned n = 0; n < sizeof(names) / sizeof(names[0]); ++n) {
            const uint32_t *code = dlsym(RTLD_DEFAULT, names[n]);
            if (!code) { [items addObject:@{@"name": @(names[n]), @"missing": @YES}]; continue; }
            NSMutableString *hex = [NSMutableString string];
            NSMutableArray *branches = [NSMutableArray array];
            for (unsigned i = 0; i < 96; ++i) {
                const uint8_t *bytes = (const uint8_t *)&code[i];
                for (unsigned j = 0; j < 4; ++j) [hex appendFormat:@"%02x", bytes[j]];
                if ((code[i] & 0x7c000000) == 0x14000000) {
                    int64_t offset = ((int64_t)(int32_t)(code[i] << 6)) >> 4;
                    const void *destination = (const uint8_t *)&code[i] + offset;
                    Dl_info info = {0};
                    dladdr(destination, &info);
                    [branches addObject:@{@"offset": @(i * 4), @"destination": @((uintptr_t)destination),
                        @"symbol": info.dli_sname ? @(info.dli_sname) : @"unknown"}];
                }
            }
            [items addObject:@{@"name": @(names[n]), @"address": @((uintptr_t)code),
                @"bytes": hex, @"branches": branches}];
        }
        NSData *json = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
        fwrite(json.bytes, 1, json.length, stdout);
    }
    return 0;
}
