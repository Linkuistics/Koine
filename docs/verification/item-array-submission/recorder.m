// Disposable recording application (k146). Never shipped. Logs every Apple Event it receives in arrival
// order to /tmp/k146-rec.jsonl: event class/id, item descriptor types, and the raw file-URL bytes (base64)
// of each direct-object item. It reads no file content.
#import <AppKit/AppKit.h>
#import <unistd.h>

static NSString *const kLog = @"/tmp/k146-rec.jsonl";
static int gSeq;
static void Append(NSDictionary *d) {
    NSMutableDictionary *m = [d mutableCopy]; m[@"seq"] = @(gSeq++); m[@"at"] = @([[NSDate date] timeIntervalSince1970]); m[@"pid"] = @(getpid());
    NSData *j = [NSJSONSerialization dataWithJSONObject:m options:NSJSONWritingSortedKeys error:nil];
    FILE *f = fopen(kLog.fileSystemRepresentation, "a"); if (!f) return;
    fwrite(j.bytes, 1, j.length, f); fputc('\n', f); fclose(f);
}
static NSString *Four(DescType t) { char c[5] = {(char)(t >> 24), (char)(t >> 16), (char)(t >> 8), (char)t, 0}; return @(c); }

@interface R : NSObject <NSApplicationDelegate> @end
@implementation R
- (void)handle:(NSAppleEventDescriptor *)ev reply:(NSAppleEventDescriptor *)reply {
    NSMutableDictionary *m = [@{@"event": [NSString stringWithFormat:@"%@/%@", Four(ev.eventClass), Four(ev.eventID)]} mutableCopy];
    NSAppleEventDescriptor *obj = [ev paramDescriptorForKeyword:keyDirectObject];
    NSMutableArray *items = [NSMutableArray array];
    if (obj) {
        NSInteger n = obj.descriptorType == typeAEList ? obj.numberOfItems : 1;
        m[@"directObjectType"] = Four(obj.descriptorType); m[@"count"] = @(n);
        for (NSInteger i = 1; i <= n; i++) {
            NSAppleEventDescriptor *it = obj.descriptorType == typeAEList ? [obj descriptorAtIndex:i] : obj;
            NSAppleEventDescriptor *u = [it coerceToDescriptorType:typeFileURL];
            NSMutableDictionary *rec = [@{@"type": Four(it.descriptorType), @"fileURLB64": u ? [u.data base64EncodedStringWithOptions:0] : [NSNull null]} mutableCopy];
            // k146 repair 1: retain the raw delivered descriptor (run 1 kept only the coerced URL, so an
            // unreadable bookmark was indistinguishable from a wrong spelling) and what Foundation can read from it.
            rec[@"rawB64"] = [it.data base64EncodedStringWithOptions:0]; rec[@"rawBytes"] = @(it.data.length);
            if (it.descriptorType == 'bmrk' || it.descriptorType == typeBookmarkData) {
                NSError *e1 = nil; NSDictionary *rv = [NSURL resourceValuesForKeys:@[NSURLPathKey] fromBookmarkData:it.data];
                rec[@"bookmarkPathB64"] = rv[NSURLPathKey] ? [[(NSString *)rv[NSURLPathKey] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] : [NSNull null];
                BOOL stale = NO;
                NSURL *ru = [NSURL URLByResolvingBookmarkData:it.data options:NSURLBookmarkResolutionWithoutUI | NSURLBookmarkResolutionWithoutMounting relativeToURL:nil bookmarkDataIsStale:&stale error:&e1];
                rec[@"resolvedPathB64"] = ru ? [[ru.path dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] : [NSNull null];
                if (e1) rec[@"resolveError"] = [NSString stringWithFormat:@"%@ %ld", e1.domain, (long)e1.code];
            }
            [items addObject:rec];
        }
    } else m[@"count"] = @0;
    m[@"items"] = items; Append(m);
}
- (void)applicationWillFinishLaunching:(NSNotification *)n {
    Append(@{@"event": @"launched"});
    NSAppleEventManager *am = NSAppleEventManager.sharedAppleEventManager;
    for (NSNumber *i in @[@(kAEOpenDocuments), @(kAEOpenApplication), @(kAEReopenApplication)])
        [am setEventHandler:self andSelector:@selector(handle:reply:) forEventClass:kCoreEventClass andEventID:i.unsignedIntValue];
}
@end
int main(void) {
    @autoreleasepool { NSApplication *a = NSApplication.sharedApplication; R *r = [R new]; a.delegate = r;
        [a setActivationPolicy:NSApplicationActivationPolicyAccessory]; [a run]; }
    return 0;
}
