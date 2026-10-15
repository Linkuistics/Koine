// Disposable native diagnostic (k146, derived from k143's probe). Never shipped. Launch ONLY in an isolated VM.
// Question: can LSOpenItemsWithRole / LSOpenFromRefSpec deliver the original file spelling of a
// reference returned by k143's flat named-child walk ("submit" mode, one API call per process)?
// Inherited k143 text follows. Question there: can flat catalog enumeration acquire the reference? No long path ever reaches a constructor: fixtures are made with mkdirat/openat and the
// walk starts from one short FSRef and follows only returned child FSRefs. Cases arrive as JSON;
// every record is appended to a JSONL file. FSRef bytes stay opaque (never printed or edited).
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <fcntl.h>
#import <sys/attr.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <unistd.h>

enum { kMaxBatch = 8, kMaxBatches = 4, kMaxLevels = 32 };

static NSString *B64(const char *s) { return [[NSData dataWithBytes:s length:strlen(s)] base64EncodedStringWithOptions:0]; }
static NSString *Now(void) { return [NSString stringWithFormat:@"%.3f", [[NSDate date] timeIntervalSince1970]]; }
static void Append(NSString *file, NSDictionary *d) {
    NSData *j = [NSJSONSerialization dataWithJSONObject:d options:NSJSONWritingSortedKeys error:nil];
    FILE *f = fopen(file.fileSystemRepresentation, "a");
    if (!f) return;
    fwrite(j.bytes, 1, j.length, f); fputc('\n', f); fclose(f);
}
static NSString *UniName(const HFSUniStr255 *n) {
    return [NSString stringWithCharacters:n->unicode length:n->length];
}
static BOOL NameIs(const HFSUniStr255 *n, NSString *want) {
    NSUInteger len = want.length; if (n->length != len) return NO;
    for (NSUInteger i = 0; i < len; i++) if (n->unicode[i] != [want characterAtIndex:i]) return NO;
    return YES;
}

// ---- fixtures: parent-relative creation only ----
static int MkdirChain(int fd, const char *name) { if (mkdirat(fd, name, 0755) != 0 && errno != EEXIST) return -1; return openat(fd, name, O_RDONLY | O_DIRECTORY); }
static void WriteAt(int fd, const char *name, const char *content) {
    int f = openat(fd, name, O_WRONLY | O_CREAT | O_TRUNC, 0644); if (f >= 0) { write(f, content, strlen(content)); close(f); } }
static NSDictionary *Err(int e) { return @{@"errno": @(e), @"message": @(strerror(e))}; }

// object path length is exactly `target` original UTF-8 bytes (ASCII components, each <= 245 bytes)
static NSDictionary *MakeFixture(NSDictionary *c) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    NSString *root = c[@"root"]; BOOL isDir = [c[@"kind"] isEqual:@"dir"]; int target = [c[@"target"] intValue];
    NSString *obj = isDir ? @"obj" : @"obj.txt", *decoy = isDir ? @"dec" : @"dec.txt";
    int fd = open("/", O_RDONLY | O_DIRECTORY); NSMutableString *dir = [NSMutableString string];
    for (NSString *p in [root componentsSeparatedByString:@"/"]) { if (!p.length) continue; int n = MkdirChain(fd, p.UTF8String); close(fd); if (n < 0) { m[@"error"] = Err(errno); return m; } fd = n; [dir appendFormat:@"/%@", p]; }
    NSMutableArray *comps = [NSMutableArray array];
    int want = target - 1 - (int)obj.length;
    for (int k = 1; (int)dir.length < want && k < 40; k++) {
        int remaining = want - (int)dir.length, room = remaining - 1, sz;
        if (room <= 245) sz = room; else { sz = 245; if (room - sz < 2) sz = room - 2; }
        if (sz < 1) { m[@"error"] = @{@"message": @"cannot place component"}; return m; }
        char name[256]; memset(name, 'a' + k % 26, sz); name[sz] = 0;
        if (sz >= 4) { name[0] = 'L'; name[1] = '0' + (k / 10) % 10; name[2] = '0' + k % 10; name[3] = '_'; }
        int n = MkdirChain(fd, name); if (n < 0) { m[@"error"] = Err(errno); m[@"failedComponent"] = @(k); return m; }
        close(fd); fd = n; [dir appendFormat:@"/%s", name]; [comps addObject:B64(name)];
    }
    if (isDir) {
        for (NSString *nm in @[obj, decoy]) { mkdirat(fd, nm.UTF8String, 0755); int o = openat(fd, nm.UTF8String, O_RDONLY | O_DIRECTORY); if (o >= 0) { WriteAt(o, "inner.txt", "inner\n"); close(o); } }
    } else {
        WriteAt(fd, obj.UTF8String, "k146 object\n"); WriteAt(fd, decoy.UTF8String, "k146 decoy\n");
    }
    close(fd);
    m[@"rootB64"] = B64(root.UTF8String); m[@"componentsB64"] = comps; m[@"obj"] = obj; m[@"decoy"] = decoy;
    m[@"kind"] = c[@"kind"]; m[@"target"] = @(target);
    m[@"objectPathLength"] = @(dir.length + 1 + obj.length);  // computed by construction
    m[@"componentLengths"] = ({ NSMutableArray *a = [NSMutableArray array]; for (NSString *b in comps) [a addObject:@([[[NSData alloc] initWithBase64EncodedString:b options:0] length])]; a; });
    return m;
}

// ---- volume facts for the fixture root (short path) ----
static NSDictionary *VolumeFacts(NSString *path) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    struct statfs sf; if (statfs(path.fileSystemRepresentation, &sf) == 0) { m[@"fstypename"] = @(sf.f_fstypename); m[@"mntonname"] = @(sf.f_mntonname); m[@"mntfromname"] = @(sf.f_mntfromname); m[@"fsid"] = @[@(sf.f_fsid.val[0]), @(sf.f_fsid.val[1])]; }
    struct attrlist al = {0}; al.bitmapcount = ATTR_BIT_MAP_COUNT; al.volattr = ATTR_VOL_INFO | ATTR_VOL_CAPABILITIES;
    struct { u_int32_t length; vol_capabilities_attr_t caps; } __attribute__((packed)) buf = {0};
    if (getattrlist(path.fileSystemRepresentation, &al, &buf, sizeof buf, 0) == 0) {
        NSMutableArray *cap = [NSMutableArray array], *valid = [NSMutableArray array];
        for (int i = 0; i < 4; i++) { [cap addObject:@(buf.caps.capabilities[i])]; [valid addObject:@(buf.caps.valid[i])]; }
        m[@"capabilities"] = cap; m[@"valid"] = valid;
        u_int32_t bit = VOL_CAP_FMT_64BIT_OBJECT_IDS;
        m[@"VOL_CAP_FMT_64BIT_OBJECT_IDS"] = @{@"validBitSet": @((buf.caps.valid[VOL_CAPABILITIES_FORMAT] & bit) != 0), @"capabilityBitSet": @((buf.caps.capabilities[VOL_CAPABILITIES_FORMAT] & bit) != 0)};
        m[@"VOL_CAP_FMT_PERSISTENTOBJECTIDS"] = @{@"validBitSet": @((buf.caps.valid[VOL_CAPABILITIES_FORMAT] & VOL_CAP_FMT_PERSISTENTOBJECTIDS) != 0), @"capabilityBitSet": @((buf.caps.capabilities[VOL_CAPABILITIES_FORMAT] & VOL_CAP_FMT_PERSISTENTOBJECTIDS) != 0)};
    } else m[@"getattrlistError"] = Err(errno);
    return m;
}

// ---- flat enumeration of one directory FSRef ----
// Finds `want` (and optionally `want2`). Stops after a matched want (intermediate levels), a completed
// iteration (errFSNoMoreItems) or the batch bound. Valid entries are processed even with errFSNoMoreItems.
typedef struct { BOOL found, found2, isDir, isDir2; FSRef ref, ref2; UInt32 nodeID, nodeID2; } Found;
static NSDictionary *IterFind(const FSRef *dir, NSString *want, NSString *want2, Found *out, NSString **stage) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary]; *stage = nil;
    FSIterator it = NULL; OSErr o = FSOpenIterator(dir, kFSIterateFlat, &it); m[@"FSOpenIterator"] = @(o);
    if (o != noErr) { *stage = @"FSOpenIterator"; return m; }
    NSMutableArray *batches = [NSMutableArray array]; m[@"batches"] = batches; BOOL completed = NO;
    for (int b = 0; b < kMaxBatches && !completed; b++) {
        FSCatalogInfo infos[kMaxBatch]; FSRef refs[kMaxBatch]; HFSUniStr255 names[kMaxBatch];
        memset(infos, 0, sizeof infos); memset(refs, 0, sizeof refs); memset(names, 0, sizeof names);
        ItemCount actual = 0; Boolean changed = false;
        OSErr e = FSGetCatalogInfoBulk(it, kMaxBatch, &actual, &changed, kFSCatInfoNodeFlags | kFSCatInfoNodeID, infos, refs, NULL, names);
        NSMutableArray *nm = [NSMutableArray array];
        for (ItemCount i = 0; i < actual && i < kMaxBatch; i++) {
            NSString *s = UniName(&names[i]); [nm addObject:B64(s.UTF8String)];
            if (!out->found && NameIs(&names[i], want)) { out->found = YES; out->ref = refs[i]; out->isDir = (infos[i].nodeFlags & kFSNodeIsDirectoryMask) != 0; out->nodeID = infos[i].nodeID; }
            if (want2 && !out->found2 && NameIs(&names[i], want2)) { out->found2 = YES; out->ref2 = refs[i]; out->isDir2 = (infos[i].nodeFlags & kFSNodeIsDirectoryMask) != 0; out->nodeID2 = infos[i].nodeID; }
        }
        [batches addObject:@{@"index": @(b), @"status": @(e), @"actual": @(actual), @"containerChanged": @(changed), @"namesB64": nm}];
        if (e == errFSNoMoreItems) completed = YES;
        else if (e != noErr) { *stage = @"FSGetCatalogInfoBulk"; break; }
        else if (out->found && (!want2 || out->found2)) break;
    }
    m[@"completed"] = @(completed);
    if (!*stage && !completed && !(out->found && (!want2 || out->found2))) *stage = @"batch-bound-exhausted";
    OSErr c = FSCloseIterator(it); m[@"FSCloseIterator"] = @(c);
    return m;
}

static NSDictionary *CatInfo(const FSRef *ref, FSRef *parentOut) {
    FSCatalogInfo info; memset(&info, 0, sizeof info); HFSUniStr255 name; memset(&name, 0, sizeof name);
    OSErr e = FSGetCatalogInfo(ref, kFSCatInfoNodeFlags | kFSCatInfoVolume | kFSCatInfoParentDirID | kFSCatInfoNodeID, &info, &name, NULL, parentOut);
    NSMutableDictionary *m = [@{@"status": @(e)} mutableCopy];
    if (e == noErr) { m[@"nodeFlags"] = @(info.nodeFlags); m[@"volume"] = @(info.volume); m[@"parentDirID"] = @(info.parentDirID); m[@"nodeID"] = @(info.nodeID); m[@"nameB64"] = B64(UniName(&name).UTF8String); }
    return m;
}

// Independent native consumers of an acquired reference. Each status stands alone.
static NSDictionary *Consume(const FSRef *ref, const FSRef *decoy, const FSRef *prevDir) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    FSRef parent; memset(&parent, 0, sizeof parent);
    NSMutableDictionary *ci = [CatInfo(ref, &parent) mutableCopy]; m[@"FSGetCatalogInfo"] = ci;
    if (prevDir && [ci[@"status"] intValue] == noErr) ci[@"parentComparedToWalkedDirectory"] = @(FSCompareFSRefs(&parent, prevDir));
    FSRef copy = *ref; m[@"FSCompareFSRefs_sameBytesCopy"] = @(FSCompareFSRefs(ref, &copy));
    if (decoy) m[@"FSCompareFSRefs_sameParentDecoy"] = @(FSCompareFSRefs(ref, decoy));
    LSItemInfoRecord rec; memset(&rec, 0, sizeof rec);
    OSStatus ls = LSCopyItemInfoForRef(ref, kLSRequestExtension | kLSRequestTypeCreator | kLSRequestAllFlags, &rec);
    NSMutableDictionary *li = [@{@"status": @(ls)} mutableCopy];
    if (ls == noErr) { li[@"flags"] = @(rec.flags); li[@"filetype"] = @(rec.filetype); li[@"creator"] = @(rec.creator); li[@"extension"] = rec.extension ? (__bridge id)rec.extension : (id)[NSNull null]; if (rec.extension) CFRelease(rec.extension); }
    m[@"LSCopyItemInfoForRef"] = li;
    CFTypeRef ct = NULL; OSStatus ca = LSCopyItemAttribute(ref, kLSRolesAll, kLSItemContentType, &ct);
    m[@"LSCopyItemAttribute_contentType"] = @{@"status": @(ca), @"value": ct ? [(__bridge id)ct description] : (id)[NSNull null]};
    if (ct) CFRelease(ct);
    FSRef app; memset(&app, 0, sizeof app); CFURLRef appURL = NULL; OSStatus ha = LSGetApplicationForItem(ref, kLSRolesAll, &app, &appURL);
    m[@"LSGetApplicationForItem"] = @{@"status": @(ha), @"appURLB64": appURL ? B64(((__bridge NSURL *)appURL).fileSystemRepresentation) : (id)[NSNull null]};
    if (appURL) CFRelease(appURL);
    if ([ci[@"status"] intValue] == noErr) {
        FSRef resolved; memset(&resolved, 0, sizeof resolved);
        OSStatus rs = FSResolveNodeID((FSVolumeRefNum)[ci[@"volume"] intValue], (UInt32)[ci[@"nodeID"] unsignedIntValue], &resolved);
        NSMutableDictionary *r = [@{@"status": @(rs), @"inputVolume": ci[@"volume"], @"inputNodeID": ci[@"nodeID"], @"provenance": @"FSGetCatalogInfo outputs of the enumerated reference; consumption test only"} mutableCopy];
        if (rs == noErr) { r[@"FSCompareFSRefs_resolvedVsEnumerated"] = @(FSCompareFSRefs(&resolved, ref)); r[@"resolvedCatalogInfo"] = CatInfo(&resolved, NULL); }
        m[@"FSResolveNodeID"] = r;
    }
    return m;
}

static FSRef gAcquired; static BOOL gHaveAcquired;
// ---- walk: short root -> flat iterators only ----
static NSDictionary *Walk(NSDictionary *c) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    NSString *root = c[@"root"], *obj = c[@"obj"], *decoy = c[@"decoy"]; BOOL isDir = [c[@"kind"] isEqual:@"dir"];
    NSMutableArray *comps = [NSMutableArray array];
    for (NSString *b in c[@"componentsB64"] ?: @[]) [comps addObject:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:b options:0] encoding:NSUTF8StringEncoding]];
    m[@"rootLength"] = @(root.length); m[@"expectedObjectPathLength"] = c[@"objectPathLength"] ?: [NSNull null];
    FSRef cur; Boolean d = false; OSStatus s = FSPathMakeRef((const UInt8 *)root.UTF8String, &cur, &d);
    m[@"FSPathMakeRef_shortRoot"] = @{@"status": @(s), @"isDirectory": @(d)};
    if (s != noErr || !d) { m[@"firstFailedStage"] = @"short-root-reference"; return m; }
    NSMutableArray *levels = [NSMutableArray array]; m[@"levels"] = levels;
    long cum = root.length; NSString *failed = nil;
    if (comps.count + 1 > kMaxLevels) { m[@"firstFailedStage"] = @"level-bound"; return m; }
    for (NSUInteger i = 0; i < comps.count && !failed; i++) {
        Found f; memset(&f, 0, sizeof f); NSString *stage = nil;
        NSDictionary *r = IterFind(&cur, comps[i], nil, &f, &stage);
        cum += 1 + (long)[comps[i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *lv = [@{@"level": @(i + 1), @"role": @"directory", @"nameLength": @([comps[i] length]), @"cumulativeOriginalBytes": @(cum), @"iteration": r, @"matchedExactName": @(f.found), @"matchedIsDirectory": @(f.isDir)} mutableCopy];
        [levels addObject:lv];
        if (stage) { failed = stage; lv[@"failedStage"] = stage; break; }
        if (!f.found) { failed = @"name-not-found"; lv[@"failedStage"] = failed; break; }
        if (!f.isDir) { failed = @"matched-not-directory"; lv[@"failedStage"] = failed; break; }
        cur = f.ref;
        FSRef pr; NSDictionary *ci = CatInfo(&cur, &pr); lv[@"FSGetCatalogInfo_afterDescent"] = ci[@"status"];
        // k143 repair 1: this status is recorded but no longer ends the walk; the charter's walk ends at an
        // iterator/enumeration failure, and a catalog-info consumer failure hid FSOpenIterator behaviour.
        if ([ci[@"status"] intValue] != noErr && !lv[@"firstConsumerFailure"]) lv[@"firstConsumerFailure"] = @"FSGetCatalogInfo-after-descent";
    }
    if (failed) { m[@"firstFailedStage"] = failed; m[@"walkedDirectoryBytes"] = @(cum); return m; }
    // final directory: look for the object and its same-parent decoy
    Found f; memset(&f, 0, sizeof f); NSString *stage = nil;
    NSDictionary *r = IterFind(&cur, obj, decoy, &f, &stage);
    cum += 1 + (long)obj.length;
    NSMutableDictionary *lv = [@{@"level": @(comps.count + 1), @"role": @"object-and-decoy", @"cumulativeOriginalBytes": @(cum), @"iteration": r, @"matchedExactName": @(f.found), @"decoyMatched": @(f.found2), @"matchedIsDirectory": @(f.isDir)} mutableCopy];
    [levels addObject:lv];
    m[@"objectPathLengthTraversed"] = @(cum);
    if (stage && !(f.found && f.found2)) { m[@"firstFailedStage"] = stage; lv[@"failedStage"] = stage; if (!f.found) return m; }
    if (!f.found) { m[@"firstFailedStage"] = @"object-not-found-in-completed-iteration"; m[@"objectOutcome"] = [(stage ?: @"") length] ? @"incomplete" : @"completed-no-match"; return m; }
    m[@"objectAcquired"] = @YES; m[@"objectTypeMatches"] = @(f.isDir == isDir);
    gAcquired = f.ref; gHaveAcquired = YES;
    if (c[@"noConsumers"]) return m;  // submit mode: no other native consumer touches the reference first
    if (c[@"pathControl"]) {
        FSRef whole; Boolean wd = false; OSStatus ps = FSPathMakeRef((const UInt8 *)[c[@"pathControl"] UTF8String], &whole, &wd);
        NSMutableDictionary *pc = [@{@"FSPathMakeRef_status": @(ps)} mutableCopy];
        if (ps == noErr) pc[@"FSCompareFSRefs_wholePathVsEnumerated"] = @(FSCompareFSRefs(&whole, &f.ref));
        m[@"shortSameObjectControl"] = pc;
    }
    m[@"consumers"] = Consume(&f.ref, f.found2 ? &f.ref2 : NULL, &cur);
    if (f.found2) m[@"decoyConsumers"] = @{@"FSGetCatalogInfo": CatInfo(&f.ref2, NULL)};
    if (isDir) { // descend into the acquired directory itself through its returned reference
        Found g; memset(&g, 0, sizeof g); NSString *st2 = nil; NSDictionary *ir = IterFind(&f.ref, @"inner.txt", nil, &g, &st2);
        m[@"insideObjectDirectory"] = @{@"iteration": ir, @"innerMatched": @(g.found), @"failedStage": st2 ?: [NSNull null]};
    }
    return m;
}

// ---- submission: one named opener, one document, explicit short app reference (k146) ----
static NSString *RefPath(const FSRef *r) {
    UInt8 buf[4096]; OSStatus e = FSRefMakePath(r, buf, sizeof buf);
    return e == noErr ? [NSString stringWithUTF8String:(const char *)buf] : [NSString stringWithFormat:@"status %d", (int)e];
}
static NSDictionary *Submit(NSMutableDictionary *c) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary];
    NSString *api = c[@"api"], *appPath = c[@"appPath"]; c[@"noConsumers"] = @YES;
    gHaveAcquired = NO;
    NSDictionary *w = Walk(c); m[@"walk"] = w;
    if (!gHaveAcquired) { m[@"firstFailedStage"] = w[@"firstFailedStage"] ?: @"acquisition"; return m; }
    // independent verification of the short application reference before any submission
    FSRef app, app2; Boolean d1 = false, d2 = false;
    OSStatus a1 = FSPathMakeRef((const UInt8 *)appPath.UTF8String, &app, &d1), a2 = FSPathMakeRef((const UInt8 *)appPath.UTF8String, &app2, &d2);
    FSRef par; NSDictionary *ci = a1 == noErr ? CatInfo(&app, &par) : @{@"status": @(a1)};
    NSString *back = a1 == noErr ? RefPath(&app) : @"";
    BOOL appOk = a1 == noErr && a2 == noErr && d1 && FSCompareFSRefs(&app, &app2) == noErr && [ci[@"status"] intValue] == noErr && [back isEqual:appPath];
    m[@"appReference"] = @{@"FSPathMakeRef": @[@(a1), @(a2)], @"isDirectory": @(d1), @"compare": @(a1 == noErr && a2 == noErr ? FSCompareFSRefs(&app, &app2) : -1),
                           @"catalog": ci, @"pathRoundTrip": back, @"pathBytes": @(appPath.length), @"verified": @(appOk)};
    if (!appOk) { m[@"firstFailedStage"] = @"short-app-reference"; return m; }
    ProcessSerialNumber psn = {0, 0}; FSRef launched; memset(&launched, 0, sizeof launched);
    double t0 = [[NSDate date] timeIntervalSince1970]; CFAbsoluteTime mono0 = CFAbsoluteTimeGetCurrent(); OSStatus st = -1;
    NSMutableDictionary *call = [@{@"api": api, @"documentsPassed": @1, @"flags": @(kLSLaunchDefaults), @"startedAt": @(t0)} mutableCopy];
    if ([api isEqual:@"LSOpenItemsWithRole"]) {
        LSApplicationParameters ap; memset(&ap, 0, sizeof ap); ap.version = 0; ap.flags = kLSLaunchDefaults; ap.application = &app;
        st = LSOpenItemsWithRole(&gAcquired, 1, kLSRolesAll, NULL, &ap, &psn, 1);
        call[@"psn"] = @{@"high": @(psn.highLongOfPSN), @"low": @(psn.lowLongOfPSN), @"note": @"optional output; not a Koine receipt"};
    } else {
        LSLaunchFSRefSpec spec; memset(&spec, 0, sizeof spec); spec.appRef = &app; spec.numDocs = 1; spec.itemRefs = &gAcquired; spec.launchFlags = kLSLaunchDefaults;
        st = LSOpenFromRefSpec(&spec, &launched);
        call[@"launchedRef"] = @{@"path": RefPath(&launched), @"note": @"optional output; not a Koine receipt"};
    }
    call[@"status"] = @(st); call[@"seconds"] = @(CFAbsoluteTimeGetCurrent() - mono0); call[@"finishedAt"] = Now();
    m[@"call"] = call;
    [NSThread sleepForTimeInterval:1.0];  // keep the submitting process alive while LS queues the event
    return m;
}

// ---- app delegate ----
@interface D : NSObject <NSApplicationDelegate> @end
@implementation D
- (void)applicationDidFinishLaunching:(NSNotification *)n {
    NSArray *a = NSProcessInfo.processInfo.arguments;
    if (a.count < 4 || ![a[1] isEqual:@"run"]) return;
    NSString *cases = a[2], *out = a[3];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *cs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:cases] options:0 error:nil];
        for (NSDictionary *c in cs) {
            NSString *mode = c[@"mode"]; NSDictionary *res = nil; double t = [[NSDate date] timeIntervalSince1970];
            @try {
                if ([mode isEqual:@"mkfixture"]) res = MakeFixture(c);
                else if ([mode isEqual:@"volume"]) res = VolumeFacts(c[@"path"]);
                else if ([mode isEqual:@"walk"]) res = Walk(c);
                else if ([mode isEqual:@"submit"]) res = Submit([c mutableCopy]);
                else res = @{@"error": @"unknown mode"};
            } @catch (NSException *e) { res = @{@"exception": e.description}; }
            Append(out, @{@"id": c[@"id"] ?: @"", @"mode": mode, @"startedAt": @(t), @"finishedAt": Now(), @"pid": @(getpid()), @"result": res ?: @{}});
        }
        Append(out, @{@"id": @"__done__"});
        dispatch_async(dispatch_get_main_queue(), ^{ [NSApp terminate:nil]; });
    });
}
@end
int main(int argc, char **argv) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication; D *d = [D new]; app.delegate = d;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory]; [app run]; }
    return 0;
}
