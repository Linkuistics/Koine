/* Declaration/link check only. Never execute this probe as native acceptance. */
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <fcntl.h>
#include <sys/fsgetpath.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <unistd.h>

int main(void) {
    int (*open_component)(int, const char *, int, ...) = openat;
    int (*inspect_component)(int, const char *, struct stat *, int) = fstatat;
    ssize_t (*read_link)(int, const char *, char *, size_t) = readlinkat;
    ssize_t (*observe_path)(char *, size_t, fsid_t *, uint64_t) = fsgetpath;
    OSErr (*make_ref)(const FSRef *, UniCharCount, const UniChar *, TextEncoding, FSRef *) = FSMakeFSRefUnicode;
    OSErr (*compare_ref)(const FSRef *, const FSRef *) = FSCompareFSRefs;
    OSStatus (*item_info)(const FSRef *, LSRequestedInfo, LSItemInfoRecord *) = LSCopyItemInfoForRef;
    OSStatus (*item_attribute)(const FSRef *, LSRolesMask, CFStringRef, CFTypeRef *) = LSCopyItemAttribute;
    CFURLRef (*unsupported_conversion)(CFAllocatorRef, const struct FSRef *) = CFURLCreateFromFSRef;
    return !(open_component && inspect_component && read_link && observe_path && make_ref
             && compare_ref && item_info && item_attribute && unsupported_conversion);
}
