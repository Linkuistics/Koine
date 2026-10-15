// Disposable native evidence tool (k134). Never shipped. Launch ONLY in an isolated VM.
// One executable, three bundles: probe (runs a cases file), fixture app (idle; self-reports
// the executable path it really runs from), witness (a document handler that records the
// exact bytes it is handed). Cases come from a JSON file; paths travel as base64 bytes.
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <libproc.h>
#import <mach-o/dyld.h>
#import <fcntl.h>
#import <sys/stat.h>
#import <unistd.h>
#import <copyfile.h>
#import <sys/attr.h>

static NSString *B64(const char *s) { return [[NSData dataWithBytes:s length:strlen(s)] base64EncodedStringWithOptions:0]; }
static NSString *Now(void) { return [NSString stringWithFormat:@"%.3f", [[NSDate date] timeIntervalSince1970]]; }
static NSMutableDictionary *Err(int e) { return [@{@"errno": @(e), @"message": @(strerror(e))} mutableCopy]; }
static void Append(NSString *file, NSDictionary *d) {
    NSData *j = [NSJSONSerialization dataWithJSONObject:d options:NSJSONWritingSortedKeys error:nil];
    FILE *f = fopen(file.fileSystemRepresentation, "a");
    if (!f) return;
    fwrite(j.bytes, 1, j.length, f); fputc('\n', f); fclose(f);
}
static char *CStr(NSString *b64) {
    NSData *d = [[NSData alloc] initWithBase64EncodedString:b64 options:0];
    char *s = calloc(d.length + 1, 1); memcpy(s, d.bytes, d.length); return s;
}
static NSURL *URLFromBytes(const char *p, BOOL dir) {
    return (__bridge_transfer NSURL *)CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)p, strlen(p), dir);
}

// ---- parent-relative resolver (openat/fstatat/readlinkat), active-expansion cycle tracking ----
typedef struct { char *name; int marker; dev_t d; ino_t i; } Item;
typedef struct {
    NSString *status;      // ok | enoent | enotdir | cycle | budget | error
    int err, compIndex; long nameLen, nameMax; BOOL impossible;
    NSMutableArray<NSString *> *phys; // physical component names (b64-free utf8)
    struct stat st; int parentFD; char *finalName; int links; int isLink;
} Res;

static NSMutableArray *Split(const char *p) {
    NSMutableArray *a = [NSMutableArray array]; const char *s = p;
    while (*s) { const char *e = strchr(s, '/'); size_t n = e ? (size_t)(e - s) : strlen(s);
        [a addObject:[[NSData alloc] initWithBytes:s length:n]]; if (!e) break; s = e + 1;
        if (!*s) { [a addObject:[NSData data]]; break; } }
    return a;
}
static Res Resolve(const char *path, BOOL followFinal, int budget) {
    Res r = {0}; r.status = @"ok"; r.phys = [NSMutableArray array]; r.parentFD = -1;
    int root = open("/", O_RDONLY | O_DIRECTORY);
    int fds[512]; int depth = 0; fds[0] = root;
    NSMutableArray<NSData *> *queue = [NSMutableArray array];
    NSMutableArray *kinds = [NSMutableArray array]; // parallel: @0 name, @1 marker(d,i)
    NSMutableArray *ids = [NSMutableArray array];
    NSMutableArray *comps = Split(path);
    if (path[0] == '/') [comps removeObjectAtIndex:0];
    for (NSInteger k = comps.count - 1; k >= 0; k--) { [queue addObject:comps[k]]; [kinds addObject:@0]; [ids addObject:@""]; }
    NSMutableSet *active = [NSMutableSet set];
    BOOL curDir = YES; int idx = 0; r.finalName = NULL;
    while (queue.count) {
        NSData *nd = queue.lastObject; int kind = [kinds.lastObject intValue]; NSString *mid = ids.lastObject;
        [queue removeLastObject]; [kinds removeLastObject]; [ids removeLastObject];
        if (kind == 1) { [active removeObject:mid]; continue; }
        idx++;
        char *name = calloc(nd.length + 1, 1); memcpy(name, nd.bytes, nd.length);
        BOOL last = ({ BOOL l = YES; for (NSNumber *kk in kinds) if (kk.intValue == 0) { l = NO; break; } l; });
        if (name[0] == 0 || strcmp(name, ".") == 0) {
            if (!curDir) { r.status = @"enotdir"; r.err = ENOTDIR; r.compIndex = idx; free(name); goto done; }
            free(name); continue; }
        if (!curDir) { r.status = @"enotdir"; r.err = ENOTDIR; r.compIndex = idx; r.nameLen = (long)nd.length; free(name); goto done; }
        if (strcmp(name, "..") == 0) {
            if (depth > 0) { close(fds[depth]); depth--; [r.phys removeLastObject]; }
            free(name); continue; }
        struct stat st;
        if (fstatat(fds[depth], name, &st, AT_SYMLINK_NOFOLLOW) != 0) {
            r.err = errno; r.compIndex = idx; r.nameLen = (long)nd.length; r.nameMax = fpathconf(fds[depth], _PC_NAME_MAX);
            r.impossible = (r.nameMax > 0 && r.nameLen > r.nameMax);
            r.status = r.err == ENOENT ? @"enoent" : (r.err == ENOTDIR ? @"enotdir" : @"error"); free(name); goto done; }
        if (S_ISLNK(st.st_mode) && !(last && !followFinal)) {
            NSString *key = [NSString stringWithFormat:@"%llu:%llu", (unsigned long long)st.st_dev, (unsigned long long)st.st_ino];
            if ([active containsObject:key]) { r.status = @"cycle"; r.compIndex = idx; free(name); goto done; }
            if (++r.links > budget) { r.status = @"budget"; r.compIndex = idx; free(name); goto done; }
            char buf[8192]; ssize_t n = readlinkat(fds[depth], name, buf, sizeof buf - 1);
            if (n < 0) { r.err = errno; r.status = @"error"; r.compIndex = idx; free(name); goto done; }
            buf[n] = 0; [active addObject:key];
            [queue addObject:[NSData data]]; [kinds addObject:@1]; [ids addObject:key];
            NSMutableArray *lc = Split(buf);
            if (buf[0] == '/') { while (depth > 0) { close(fds[depth]); depth--; } [r.phys removeAllObjects]; [lc removeObjectAtIndex:0]; }
            for (NSInteger k = lc.count - 1; k >= 0; k--) { [queue addObject:lc[k]]; [kinds addObject:@0]; [ids addObject:@""]; }
            free(name); continue; }
        if (S_ISDIR(st.st_mode) && !(S_ISLNK(st.st_mode))) {
            int nfd = openat(fds[depth], name, O_RDONLY | O_DIRECTORY);
            if (nfd < 0) { r.err = errno; r.status = @"error"; r.compIndex = idx; free(name); goto done; }
            fds[++depth] = nfd; [r.phys addObject:[[NSString alloc] initWithBytes:nd.bytes length:nd.length encoding:NSUTF8StringEncoding]];
            r.st = st; r.finalName = NULL; r.isLink = 0; free(name); continue; }
        // non-directory (regular, or a link we are not following)
        r.st = st; r.isLink = S_ISLNK(st.st_mode); curDir = NO;
        [r.phys addObject:[[NSString alloc] initWithBytes:nd.bytes length:nd.length encoding:NSUTF8StringEncoding]];
        r.finalName = name; r.parentFD = fds[depth]; (void)last; continue;
    }
done:
    for (int k = 0; k <= depth; k++) close(fds[k]);  // an LS-launched process has a 256-descriptor limit
    r.parentFD = -1; return r;
}

static NSDictionary *StatDict(struct stat *st) {
    return @{@"dev": @(st->st_dev), @"ino": @(st->st_ino), @"mode": @(st->st_mode), @"isDir": @(S_ISDIR(st->st_mode) != 0), @"isLink": @(S_ISLNK(st->st_mode) != 0)};
}

// ---- FSRef chain from components ----
static NSDictionary *RefChain(NSArray<NSString *> *phys, FSRef *out, BOOL *ok) {
    FSRef cur; Boolean isDir; OSStatus s = FSPathMakeRef((const UInt8 *)"/", &cur, &isDir);
    NSMutableDictionary *d = [NSMutableDictionary dictionary]; *ok = NO;
    if (s != noErr) { d[@"error"] = @(s); d[@"step"] = @"root"; return d; }
    NSInteger i = 0;
    for (NSString *c in phys) {
        NSUInteger n = [c length]; UniChar *u = malloc(n * sizeof(UniChar) + 2); [c getCharacters:u range:NSMakeRange(0, n)];
        FSRef next; OSErr e = FSMakeFSRefUnicode(&cur, n, u, kTextEncodingUnknown, &next); free(u);
        if (e != noErr) { d[@"error"] = @(e); d[@"step"] = @(i); d[@"componentUTF8Length"] = @([c lengthOfBytesUsingEncoding:NSUTF8StringEncoding]); return d; }
        cur = next; i++;
    }
    *out = cur; *ok = YES; d[@"steps"] = @(i); return d;
}

static NSString *DictId(NSData *plist) {
    NSError *e = nil; id o = [NSPropertyListSerialization propertyListWithData:plist options:0 format:NULL error:&e];
    if (![o isKindOfClass:[NSDictionary class]]) return nil;
    return o[@"CFBundleIdentifier"];
}
// component-relative plist read: openat chain below an app directory fd
static NSDictionary *PlistRoute(int appfd) {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    const char *cands[] = {"Contents/Info.plist", "Info.plist", "Resources/Info.plist", "Contents/Resources/Info.plist"};
    NSMutableArray *present = [NSMutableArray array];
    for (int k = 0; k < 4; k++) { struct stat st; if (fstatat(appfd, cands[k], &st, 0) == 0) [present addObject:@(cands[k])]; }
    d[@"layoutsPresent"] = present;
    int fd = openat(appfd, "Contents/Info.plist", O_RDONLY);
    if (fd < 0) { d[@"read"] = Err(errno); d[@"outcome"] = errno == ENOENT ? @"missing" : @"unreadable"; return d; }
    NSMutableData *data = [NSMutableData data]; char buf[4096]; ssize_t n;
    while ((n = read(fd, buf, sizeof buf)) > 0) [data appendBytes:buf length:n];
    close(fd); d[@"bytes"] = @(data.length);
    NSString *ident = DictId(data);
    d[@"identifier"] = ident ?: (id)[NSNull null]; d[@"outcome"] = ident ? @"identifier" : @"parsed-no-identifier-or-malformed";
    return d;
}

static NSDictionary *Acquire(NSDictionary *c) {
    char *path = CStr(c[@"pathb64"]); BOOL follow = [c[@"followFinal"] boolValue];
    NSMutableDictionary *o = [NSMutableDictionary dictionary];
    o[@"pathLength"] = @(strlen(path));
    Res r = Resolve(path, follow, [c[@"budget"] intValue] ?: 40);
    o[@"resolve"] = @{@"status": r.status, @"errno": @(r.err), @"componentIndex": @(r.compIndex), @"nameLength": @(r.nameLen),
                       @"nameMax": @(r.nameMax), @"impossibleComponentEstablished": @(r.impossible), @"links": @(r.links),
                       @"final": StatDict(&r.st), @"finalIsLinkNotFollowed": @(r.isLink)};
    // whole-path controls (the existing route's shape)
    NSMutableDictionary *w = [NSMutableDictionary dictionary];
    struct stat st; w[@"stat"] = stat(path, &st) == 0 ? @{@"ok": @YES, @"ino": @(st.st_ino)} : Err(errno);
    FSRef wr; Boolean dirb; OSStatus ps = FSPathMakeRef((const UInt8 *)path, &wr, &dirb); w[@"FSPathMakeRef"] = @(ps);
    char *rp = realpath(path, NULL); w[@"realpath"] = rp ? @{@"length": @(strlen(rp))} : Err(errno); free(rp);
    NSURL *u = URLFromBytes(path, NO); NSError *ue = nil; NSNumber *isApp = nil;
    [u getResourceValue:&isApp forKey:NSURLIsApplicationKey error:&ue]; w[@"URLisApplication"] = isApp ?: (ue ? @{@"error": ue.localizedDescription} : [NSNull null]);
    NSBundle *b = [NSBundle bundleWithURL:u]; w[@"NSBundleIdentifier"] = b.bundleIdentifier ?: [NSNull null];
    CFDictionaryRef bi = CFBundleCopyInfoDictionaryForURL((__bridge CFURLRef)u);
    w[@"CFBundleInfoDictionaryKeys"] = bi ? @(CFDictionaryGetCount(bi)) : [NSNull null];
    if (bi) { id v = ((__bridge NSDictionary *)bi)[@"CFBundleIdentifier"]; w[@"CFBundleInfoIdentifier"] = v ?: [NSNull null]; CFRelease(bi); }
    o[@"wholePathControls"] = w;
    if (![r.status isEqualToString:@"ok"]) return o;
    // bundle identifier by component-relative plist read (apps and any directory)
    if (S_ISDIR(r.st.st_mode)) {
        // reopen final directory fd: walk again is cheap; use parent chain via openat on phys
        int fd = open("/", O_RDONLY | O_DIRECTORY);
        for (NSString *name in r.phys) { int n = openat(fd, name.UTF8String, O_RDONLY | O_DIRECTORY); close(fd); fd = n; if (fd < 0) break; }
        if (fd >= 0) { o[@"plistRoute"] = PlistRoute(fd); close(fd); }
    }
    FSRef ref; BOOL ok; o[@"refChain"] = RefChain(r.phys, &ref, &ok);
    if (!ok) return o;
    LSItemInfoRecord info; memset(&info, 0, sizeof info);
    OSStatus ls = LSCopyItemInfoForRef(&ref, kLSRequestAllFlags | kLSRequestExtension, &info);
    NSMutableDictionary *ii = [NSMutableDictionary dictionary]; ii[@"status"] = @(ls);
    if (ls == noErr) { ii[@"flags"] = @(info.flags);
        ii[@"application"] = @((info.flags & kLSItemInfoIsApplication) != 0); ii[@"package"] = @((info.flags & kLSItemInfoIsPackage) != 0);
        ii[@"alias"] = @((info.flags & kLSItemInfoIsAliasFile) != 0); ii[@"symlink"] = @((info.flags & kLSItemInfoIsSymlink) != 0);
        ii[@"plain"] = @((info.flags & kLSItemInfoIsPlainFile) != 0); ii[@"container"] = @((info.flags & kLSItemInfoIsContainer) != 0);
        ii[@"extension"] = (__bridge NSString *)info.extension ?: [NSNull null]; }
    o[@"itemInfo"] = ii;
    CFTypeRef ct = NULL; OSStatus cs = LSCopyItemAttribute(&ref, kLSRolesAll, kLSItemContentType, &ct);
    o[@"contentType"] = @{@"status": @(cs), @"value": ct ? [(__bridge id)ct description] : (id)[NSNull null]};
    if (ct) CFRelease(ct);
    FSRef again; BOOL ok2; RefChain(r.phys, &again, &ok2);
    o[@"compareSelf"] = ok2 ? @(FSCompareFSRefs(&ref, &again)) : @"second-chain-failed";
    NSMutableArray *ph = [r.phys mutableCopy]; if (ph.count > 1) [ph removeLastObject];
    FSRef par; BOOL ok3; RefChain(ph, &par, &ok3);
    o[@"compareDifferent(parent)"] = ok3 ? @(FSCompareFSRefs(&ref, &par)) : @"parent-chain-failed";
    if (ps == noErr) o[@"compareWholeVsComponent"] = @(FSCompareFSRefs(&wr, &ref));
    return o;
}

static NSDictionary *Registration(NSDictionary *c) {
    NSMutableDictionary *o = [NSMutableDictionary dictionary];
    NSString *ident = c[@"identifier"]; char *exp = CStr(c[@"expectedb64"]);
    NSURL *pref = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:ident];
    NSArray *all = [[NSWorkspace sharedWorkspace] URLsForApplicationsWithBundleIdentifier:ident];
    Res e = Resolve(exp, YES, 40); struct stat est = e.st;
    NSMutableArray *rows = [NSMutableArray array];
    for (NSURL *u in all) {
        const char *p = u.fileSystemRepresentation; Res r = Resolve(p, YES, 40);
        [rows addObject:@{@"pathb64": B64(p), @"length": @(strlen(p)), @"resolve": r.status, @"sameObjectAsExpected": @([r.status isEqual:@"ok"] && r.st.st_ino == est.st_ino && r.st.st_dev == est.st_dev)}];
    }
    o[@"preferred"] = pref ? @{@"pathb64": B64(pref.fileSystemRepresentation), @"length": @(strlen(pref.fileSystemRepresentation))} : [NSNull null];
    o[@"all"] = rows; return o;
}
static NSDictionary *LSBind(NSDictionary *c) {
    char *path = CStr(c[@"pathb64"]); Res r = Resolve(path, YES, 40); BOOL ok; FSRef ref;
    NSMutableDictionary *o = [NSMutableDictionary dictionary];
    NSDictionary *chain = RefChain(r.phys, &ref, &ok); o[@"refChain"] = chain; if (!ok) return o;
    FSRef appRef; CFURLRef appURL = NULL; OSStatus s = LSGetApplicationForItem(&ref, kLSRolesAll, &appRef, &appURL);
    o[@"status"] = @(s); o[@"appURL"] = appURL ? B64(((__bridge NSURL *)appURL).fileSystemRepresentation) : (id)[NSNull null];
    return o;
}

// ---- submission ----
static NSDictionary *Proc(pid_t pid, NSRunningApplication *app) {
    NSMutableDictionary *o = [NSMutableDictionary dictionary]; char buf[4 * MAXPATHLEN]; memset(buf, 0, sizeof buf);
    int n = proc_pidpath(pid, buf, sizeof buf);
    o[@"pid"] = @(pid);
    o[@"proc_pidpath"] = n > 0 ? @{@"length": @(n), @"b64": B64(buf)} : Err(errno);
    o[@"executableURL"] = app.executableURL ? @{@"length": @(strlen(app.executableURL.fileSystemRepresentation)), @"b64": B64(app.executableURL.fileSystemRepresentation)} : [NSNull null];
    o[@"bundleURL"] = app.bundleURL ? B64(app.bundleURL.fileSystemRepresentation) : (id)[NSNull null];
    o[@"bundleIdentifier"] = app.bundleIdentifier ?: [NSNull null];
    return o;
}
static NSWorkspaceOpenConfiguration *Config(BOOL substitute) {
    NSWorkspaceOpenConfiguration *c = [NSWorkspaceOpenConfiguration configuration];
    c.activates = YES; c.createsNewApplicationInstance = NO; c.allowsRunningApplicationSubstitution = substitute;
    c.promptsUserIfNeeded = NO; return c;
}
static NSDictionary *Submit(NSDictionary *c, NSString *mode) {
    NSMutableDictionary *o = [NSMutableDictionary dictionary]; dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block NSDictionary *res = nil; double t0 = [[NSDate date] timeIntervalSince1970];
    BOOL sub = [c[@"substitute"] boolValue];
    if ([mode isEqual:@"reveal"]) {
        char *p = CStr(c[@"pathb64"]); NSString *s = [NSString stringWithUTF8String:p];
        BOOL acc = [[NSWorkspace sharedWorkspace] selectFile:s inFileViewerRootedAtPath:@""]; o[@"accepted"] = @(acc); o[@"submittedLength"] = @(strlen(p)); return o; }
    NSURL *app = nil; NSURL *doc = nil;
    if (c[@"apppathb64"]) app = URLFromBytes(CStr(c[@"apppathb64"]), YES);
    if (c[@"pathb64"]) doc = URLFromBytes(CStr(c[@"pathb64"]), NO);
    if ([mode isEqual:@"open"] && !app) { app = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:doc]; o[@"defaultHandler"] = app ? B64(app.fileSystemRepresentation) : (id)[NSNull null]; if (!app) { o[@"outcome"] = @"no-handler"; return o; } }
    o[@"submittedApp"] = app ? @{@"length": @(strlen(app.fileSystemRepresentation)), @"b64": B64(app.fileSystemRepresentation)} : [NSNull null];
    o[@"submittedDoc"] = doc ? @{@"length": @(strlen(doc.fileSystemRepresentation)), @"b64": B64(doc.fileSystemRepresentation)} : [NSNull null];
    void (^done)(NSRunningApplication *, NSError *) = ^(NSRunningApplication *ra, NSError *e) {
        NSMutableDictionary *r = [NSMutableDictionary dictionary]; r[@"elapsedMs"] = @(([[NSDate date] timeIntervalSince1970] - t0) * 1000);
        if (e) { r[@"error"] = @{@"domain": e.domain, @"code": @(e.code), @"message": e.localizedDescription}; }
        else if (ra) { r[@"app"] = Proc(ra.processIdentifier, ra); } else r[@"app"] = [NSNull null];
        res = r; dispatch_semaphore_signal(sem); };
    if ([mode isEqual:@"launch"]) [[NSWorkspace sharedWorkspace] openApplicationAtURL:app configuration:Config(sub) completionHandler:done];
    else [[NSWorkspace sharedWorkspace] openURLs:@[doc] withApplicationAtURL:app configuration:Config(sub) completionHandler:done];
    if (dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC)) != 0) o[@"callback"] = @"no callback in 20s"; else o[@"callback"] = res;
    return o;
}


// ---- alternate whole-path/relative acquisitions on a long object (cwd-relative = parent-relative candidate) ----
static NSDictionary *Alt(NSDictionary *c) {
    char *dir = CStr(c[@"dirb64"]); NSString *name = c[@"name"]; NSMutableDictionary *o = [NSMutableDictionary dictionary];
    Res r = Resolve(dir, YES, 40); int fd = open("/", O_RDONLY | O_DIRECTORY);
    for (NSString *n in r.phys) { int k = openat(fd, n.UTF8String, O_RDONLY | O_DIRECTORY); close(fd); fd = k; if (fd < 0) break; }
    if (fd < 0) return @{@"error": @"dir"};
    char full[4096]; snprintf(full, sizeof full, "%s/%s", dir, name.UTF8String);
    NSURL *lu = URLFromBytes(full, NO);
    LSItemInfoRecord info; memset(&info, 0, sizeof info);
    OSStatus s1 = LSCopyItemInfoForURL((__bridge CFURLRef)lu, kLSRequestAllFlags, &info);
    o[@"LSCopyItemInfoForURL(long)"] = @{@"status": @(s1), @"flags": s1 == noErr ? @(info.flags) : (id)[NSNull null]};
    NSError *e = nil; NSString *ct = nil; [lu getResourceValue:&ct forKey:NSURLTypeIdentifierKey error:&e];
    o[@"URLresource(long) typeIdentifier"] = ct ?: (e ? e.localizedDescription : [NSNull null]);
    NSNumber *ia = nil; e = nil; [lu getResourceValue:&ia forKey:NSURLIsApplicationKey error:&e];
    o[@"URLresource(long) isApplication"] = ia ?: (e ? e.localizedDescription : [NSNull null]);
    NSNumber *fid = nil; e = nil; [lu getResourceValue:&fid forKey:NSURLIsAliasFileKey error:&e];
    o[@"URLresource(long) isAliasFile"] = fid ?: (e ? e.localizedDescription : [NSNull null]);
    o[@"URLfileExists(long)"] = @([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:full]]);
    // cwd-relative spellings
    char old[4096]; getcwd(old, sizeof old);
    int cw = fchdir(fd); o[@"fchdir"] = @(cw);
    FSRef ref; Boolean isd; OSStatus p1 = FSPathMakeRef((const UInt8 *)name.UTF8String, &ref, &isd); o[@"FSPathMakeRef(cwd-relative)"] = @(p1);
    char rel[600]; snprintf(rel, sizeof rel, "./%s", name.UTF8String);
    OSStatus p2 = FSPathMakeRef((const UInt8 *)rel, &ref, &isd); o[@"FSPathMakeRef(./name)"] = @(p2);
    if (p2 == noErr) { LSItemInfoRecord i2; memset(&i2, 0, sizeof i2); OSStatus q = LSCopyItemInfoForRef(&ref, kLSRequestAllFlags, &i2); o[@"LSCopyItemInfoForRef(cwd-relative ref)"] = @{@"status": @(q), @"flags": q == noErr ? @(i2.flags) : (id)[NSNull null]}; }
    NSURL *ru = [NSURL fileURLWithPath:name]; e = nil; ia = nil; [ru getResourceValue:&ia forKey:NSURLIsApplicationKey error:&e];
    o[@"NSURL(relative) isApplication"] = ia ?: (e ? e.localizedDescription : [NSNull null]); o[@"NSURL(relative).path length"] = @(ru.path.length);
    chdir(old);
    // getattrlistat object type: native single-component attribute read, no path-length limit
    struct attrlist al; memset(&al, 0, sizeof al); al.bitmapcount = ATTR_BIT_MAP_COUNT; al.commonattr = ATTR_CMN_OBJTYPE | ATTR_CMN_FNDRINFO;
    struct { u_int32_t len; fsobj_type_t t; u_int8_t finfo[32]; } __attribute__((packed)) ab;
    int ga = getattrlistat(fd, name.UTF8String, &al, &ab, sizeof ab, 0); o[@"getattrlistat"] = ga == 0 ? @{@"objtype": @(ab.t)} : Err(errno);
    close(fd); return o;
}

// ---- fixtures ----
static int MkdirChain(int fd, const char *name) { if (mkdirat(fd, name, 0755) != 0 && errno != EEXIST) return -1; return openat(fd, name, O_RDONLY | O_DIRECTORY); }
static void WriteAt(int fd, const char *name, const char *content, mode_t mode) {
    int f = openat(fd, name, O_WRONLY | O_CREAT | O_TRUNC, mode); if (f >= 0) { write(f, content, strlen(content)); fchmod(f, mode); close(f); } }
static NSDictionary *Fixtures(NSDictionary *c) {
    NSMutableDictionary *m = [NSMutableDictionary dictionary]; char *root = CStr(c[@"rootb64"]);
    NSString *stage = c[@"stage"]; // short dir holding signed bundles to move in
    // root chain (short components)
    int fd = open("/", O_RDONLY | O_DIRECTORY); NSMutableString *acc = [NSMutableString string];
    for (NSString *p in [[NSString stringWithUTF8String:root] componentsSeparatedByString:@"/"]) { if (!p.length) continue; int n = MkdirChain(fd, p.UTF8String); close(fd); fd = n; [acc appendFormat:@"/%@", p]; }
    m[@"root"] = acc;
    int shortfd = dup(fd);
    NSMutableString *dir = [acc mutableCopy]; int dfd = fd; int target = [c[@"target"] intValue] ?: 1500;
    int want = target - 13; // "/sample.k134w" is 13 bytes: the witness document's path is exactly `target` bytes (sample.txt is 2 shorter)
    for (int k = 1; (int)[dir length] < want && k < 40; k++) {
        int room = want - (int)[dir length] - 1; int sz = room > 245 ? 245 : room; if (sz < 3) { sz = room < 1 ? 0 : room; }
        if (sz < 1) break;
        char name[256]; memset(name, 'a' + k % 26, sz); name[sz] = 0; if (sz >= 3) { name[0] = 'L'; name[1] = '0' + k % 10; name[2] = '_'; }
        int n = MkdirChain(dfd, name); if (n < 0) { m[@"error"] = Err(errno); return m; } close(dfd); dfd = n; [dir appendFormat:@"/%s", name]; }
    // components used above; build named objects in dfd (the long directory)
    char *sample = "sample.txt";
    WriteAt(dfd, sample, "a long-path plain text document\n", 0644);
    WriteAt(dfd, "sample.k134w", "witness document\n", 0644);
    WriteAt(dfd, "script.sh", "#!/bin/sh\necho k134\n", 0755);
    mkdirat(dfd, "Pack.rtfd", 0755); { int pf = openat(dfd, "Pack.rtfd", O_RDONLY | O_DIRECTORY); WriteAt(pf, "TXT.rtf", "{\\rtf1\\ansi pack}\n", 0644); close(pf); }
    mkdirat(dfd, "Folder", 0755);
    symlinkat("sample.txt", dfd, "link-to-sample");
    symlinkat("does-not-exist", dfd, "link-dangling");
    symlinkat(".", dfd, "dotlink");
    symlinkat("cycle-b", dfd, "cycle-a"); symlinkat("cycle-a", dfd, "cycle-b");
    for (int k = 0; k < 45; k++) { char a[32], b[32]; snprintf(a, 32, "chain%d", k); snprintf(b, 32, "chain%d", k + 1); symlinkat(k == 44 ? "sample.txt" : b, dfd, a); }
    symlinkat("sample.txt/more", dfd, "link-below-file");
    // malformed/missing/no-id/denied bundles (unsigned, never launched)
    const char *kinds[] = {"BadPlist.app", "NoPlist.app", "NoId.app", "Denied.app"};
    for (int k = 0; k < 4; k++) { mkdirat(dfd, kinds[k], 0755); int a = openat(dfd, kinds[k], O_RDONLY | O_DIRECTORY); mkdirat(a, "Contents", 0755); int cf = openat(a, "Contents", O_RDONLY | O_DIRECTORY);
        if (k == 0) WriteAt(cf, "Info.plist", "this is not a plist", 0644);
        if (k == 2) WriteAt(cf, "Info.plist", "<?xml version=\"1.0\"?><plist version=\"1.0\"><dict><key>CFBundleName</key><string>x</string></dict></plist>", 0644);
        if (k == 3) WriteAt(cf, "Info.plist", "<?xml version=\"1.0\"?><plist version=\"1.0\"><dict><key>CFBundleIdentifier</key><string>dev.antony.Koine.K134Denied</string></dict></plist>", 0000);
        close(cf); close(a); }
    // signed bundles moved in with renameat (preserves signature; no whole-path call)
    int sfd = open("/", O_RDONLY | O_DIRECTORY);
    for (NSString *p in [stage componentsSeparatedByString:@"/"]) { if (!p.length) continue; int n = openat(sfd, p.UTF8String, O_RDONLY | O_DIRECTORY); close(sfd); sfd = n; }
    for (NSString *app in c[@"move"]) { int rc = renameat(sfd, app.UTF8String, dfd, app.UTF8String); m[[@"move:" stringByAppendingString:app]] = @(rc == 0 ? 0 : errno); }
    // the file named by 300 bytes cannot exist: record the attempt
    char big[301]; memset(big, 'z', 300); big[300] = 0; int bf = openat(dfd, big, O_WRONLY | O_CREAT, 0644); m[@"create300ByteName"] = bf >= 0 ? @"created" : Err(errno).copy;
    m[@"longDirB64"] = B64(dir.UTF8String); m[@"longDirLength"] = @(dir.length);
    (void)shortfd; (void)sample;
    return m;
}

// ---- app delegate ----
@interface D : NSObject <NSApplicationDelegate> @property NSString *out; @property NSString *cases; @end
@implementation D
- (void)application:(NSApplication *)app openURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *u in urls) { const char *p = u.fileSystemRepresentation;
        Append(@"/tmp/koine-k134-witness.jsonl", @{@"at": Now(), @"pid": @(getpid()), @"id": NSBundle.mainBundle.bundleIdentifier ?: @"", @"deliveredLength": @(strlen(p)), @"deliveredB64": B64(p)}); }
}
- (void)applicationDidFinishLaunching:(NSNotification *)n {
    [NSProcessInfo.processInfo disableAutomaticTermination:@"k134"]; [NSProcessInfo.processInfo disableSuddenTermination];
    static id activity; activity = [NSProcessInfo.processInfo beginActivityWithOptions:(NSActivityUserInitiatedAllowingIdleSystemSleep | NSActivityLatencyCritical) reason:@"k134 measurement"];
    NSArray *a = NSProcessInfo.processInfo.arguments;
    char exe[8192]; uint32_t sz = sizeof exe; _NSGetExecutablePath(exe, &sz); char pp[4 * MAXPATHLEN] = {0}; int pl = proc_pidpath(getpid(), pp, sizeof pp);
    NSDictionary *me = @{@"at": Now(), @"pid": @(getpid()), @"id": NSBundle.mainBundle.bundleIdentifier ?: @"", @"bundleB64": B64(NSBundle.mainBundle.bundlePath.fileSystemRepresentation),
        @"_NSGetExecutablePathLength": @(strlen(exe)), @"proc_pidpathLength": @(pl), @"proc_pidpathB64": B64(pp), @"exeB64": B64(exe)};
    if (a.count < 4 || ![a[1] isEqual:@"run"]) { Append(@"/tmp/koine-k134-self.jsonl", me); return; }
    self.cases = a[2]; self.out = a[3];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *cs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:self.cases] options:0 error:nil];
        for (NSDictionary *c in cs) {
            NSString *mode = c[@"mode"]; NSDictionary *res = nil; double t = [[NSDate date] timeIntervalSince1970];
            @try {
                if ([mode isEqual:@"fixtures"]) res = Fixtures(c);
                else if ([mode isEqual:@"acquire"]) res = Acquire(c);
                else if ([mode isEqual:@"alt"]) res = Alt(c);
                else if ([mode isEqual:@"register"]) { NSURL *u = URLFromBytes(CStr(c[@"pathb64"]), YES); OSStatus rs = LSRegisterURL((__bridge CFURLRef)u, true); res = @{@"LSRegisterURL": @(rs)}; }
                else if ([mode isEqual:@"registration"]) res = Registration(c);
                else if ([mode isEqual:@"lsbind"]) res = LSBind(c);
                else if ([mode isEqual:@"defaulthandler"]) { NSURL *u = URLFromBytes(CStr(c[@"pathb64"]), NO); NSURL *h = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:u]; res = @{@"handler": h ? B64(h.fileSystemRepresentation) : (id)[NSNull null]}; }
                else res = Submit(c, mode);
            } @catch (NSException *e) { res = @{@"exception": e.description}; }
            Append(self.out, @{@"id": c[@"id"] ?: @"", @"mode": mode, @"startedAt": @(t), @"finishedAt": Now(), @"pid": @(getpid()), @"result": res ?: @{}});
            if ([c[@"pauseAfterMs"] intValue]) usleep([c[@"pauseAfterMs"] intValue] * 1000);
        }
        Append(self.out, @{@"id": @"__done__"});
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
