#include <ApplicationServices/ApplicationServices.h>
#include <mach/mach.h>
#include <bsm/libbsm.h>
#include <sys/sysctl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char **argv) {
    ProcessSerialNumber psn = {0, 0};
    pid_t pid = 0;
    OSStatus capture;
    if (argc == 3 && strcmp(argv[1], "pid") == 0) {
        pid = (pid_t)strtol(argv[2], NULL, 10);
        capture = GetProcessForPID(pid, &psn);
    } else if (argc == 3 && strcmp(argv[1], "psn") == 0) {
        uint64_t value = strtoull(argv[2], NULL, 16);
        psn.highLongOfPSN = (UInt32)(value >> 32);
        psn.lowLongOfPSN = (UInt32)value;
        capture = noErr;
    } else {
        capture = GetFrontProcess(&psn);
    }
    OSStatus resolve = GetProcessPID(&psn, &pid);
    ProcessSerialNumber again = {0, 0};
    OSStatus reverse = pid > 0 ? GetProcessForPID(pid, &again) : -1;
    char boot[128] = {0};
    size_t size = sizeof boot;
    int bootStatus = sysctlbyname("kern.bootsessionuuid", boot, &size, NULL, 0);
    mach_port_t first = MACH_PORT_NULL, second = MACH_PORT_NULL;
    kern_return_t taskStatus = task_name_for_pid(mach_task_self(), pid, &first);
    kern_return_t secondStatus = task_name_for_pid(mach_task_self(), pid, &second);
    audit_token_t audit = {0};
    mach_msg_type_number_t count = TASK_AUDIT_TOKEN_COUNT;
    kern_return_t auditStatus = task_info(first, TASK_AUDIT_TOKEN, (task_info_t)&audit, &count);
    printf("{\"capture\":%d,\"resolve\":%d,\"pid\":%d,\"psn\":\"%08x%08x\",\"reverse\":%d,\"reversePSN\":\"%08x%08x\",\"bootStatus\":%d,\"boot\":\"%s\",\"taskStatus\":%d,\"secondTaskStatus\":%d,\"samePort\":%s,\"auditStatus\":%d,\"pidversion\":%u}\n", capture, resolve, pid, (unsigned)psn.highLongOfPSN, (unsigned)psn.lowLongOfPSN, reverse, (unsigned)again.highLongOfPSN, (unsigned)again.lowLongOfPSN, bootStatus, boot, taskStatus, secondStatus, first == second ? "true" : "false", auditStatus, (unsigned)audit_token_to_pidversion(audit));
    if (MACH_PORT_VALID(first)) mach_port_deallocate(mach_task_self(), first);
    if (MACH_PORT_VALID(second)) mach_port_deallocate(mach_task_self(), second);
    return 0;
}
