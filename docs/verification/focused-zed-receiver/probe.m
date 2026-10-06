// Throwaway k155 diagnostic. Execute only in the authorized disposable guest.
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/attr.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <libproc.h>
#import <CoreGraphics/CoreGraphics.h>

static void emit(NSDictionary *row) {
    NSData *d = [NSJSONSerialization dataWithJSONObject:row options:0 error:nil];
    if (!d) { fprintf(stderr, "invalid JSON record\n"); exit(2); }
    fwrite(d.bytes, 1, d.length, stdout); fputc('\n', stdout); fflush(stdout);
}
static NSDictionary *err(NSError *e) {
    if (!e) return @{};
    NSMutableDictionary *r = [@{@"domain":e.domain, @"code":@(e.code)} mutableCopy];
    NSError *u = e.userInfo[NSUnderlyingErrorKey];
    if (u) r[@"underlying"] = @{@"domain":u.domain, @"code":@(u.code)};
    return r;
}
static NSDictionary *ident(struct stat s) {
    return @{@"device":@((long long)s.st_dev), @"inode":@((unsigned long long)s.st_ino), @"mode":@(s.st_mode)};
}
static BOOL same(struct stat a, struct stat b) { return a.st_dev == b.st_dev && a.st_ino == b.st_ino; }
static void fail(NSString *stage) { emit(@{@"event":@"failure", @"stage":stage, @"errno":@(errno)}); }
static int parentFD(NSDictionary *c, BOOL create) {
    NSString *root = c[@"root"];
    if (create && mkdir(root.fileSystemRepresentation,0700) && errno != EEXIST) { fail(@"mkdirRoot"); return -1; }
    int fd = open(root.fileSystemRepresentation,O_RDONLY|O_DIRECTORY|O_NOFOLLOW);
    if (fd < 0) { fail(@"openRoot"); return -1; }
    NSArray *parts = c[@"components"];
    if (parts.count + 1 > 32) { close(fd); errno=EOVERFLOW; fail(@"depthBound"); return -1; }
    for (NSString *p in parts) {
        if (![p length] || [p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>245 || [p containsString:@"/"]) {
            close(fd); errno=EINVAL; fail(@"componentBound"); return -1;
        }
        if (create && mkdirat(fd,p.UTF8String,0700) && errno != EEXIST) { fail(@"mkdirat"); close(fd); return -1; }
        int next = openat(fd,p.UTF8String,O_RDONLY|O_DIRECTORY|O_NOFOLLOW);
        if (next < 0) { fail(@"openatDirectory"); close(fd); return -1; }
        close(fd); fd=next;
    }
    return fd;
}
static NSString *original(NSDictionary *c) {
    NSString *p = c[@"root"];
    for (NSString *v in c[@"components"]) p=[p stringByAppendingFormat:@"/%@",v];
    return [p stringByAppendingFormat:@"/%@",c[@"name"]];
}
static BOOL directory(NSDictionary *c) { return [c[@"kind"] isEqual:@"directory"]; }
static BOOL markerRead(int fd, NSDictionary *c, BOOL decoy) {
    int child=-1, use=fd;
    if(directory(c)) {
        child=openat(fd,[c[@"child"] UTF8String],O_RDONLY|O_NOFOLLOW);
        if(child<0) { fail(@"markerChildOpen"); return NO; }
        use=child;
    }
    char b[64]={0}; ssize_t n=read(use,b,sizeof(b)); int saved=errno;
    if(child>=0) close(child);
    NSData *want=[(decoy ? c[@"decoyMarker"] : c[@"marker"]) dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ok=n>=0 && (NSUInteger)n==want.length && !memcmp(b,want.bytes,want.length);
    emit(@{@"event":@"marker",@"decoy":@(decoy),@"exact":@(ok),@"bytes":@(n),
           @"b64":n>=0 ? [[NSData dataWithBytes:b length:(NSUInteger)n] base64EncodedStringWithOptions:0] : @"",
           @"errno":@(n<0 ? saved : 0)});
    return ok;
}
static BOOL inspectOriginal(NSDictionary *c, struct stat *target, struct stat *decoy) {
    int parent=parentFD(c,NO); if(parent<0) return NO;
    struct stat p={0}; BOOL ok=fstat(parent,&p)==0;
    for(NSString *key in @[@"name",@"decoy"]) {
        int fd=openat(parent,[c[key] UTF8String],O_RDONLY|O_NOFOLLOW|(directory(c)?O_DIRECTORY:0));
        if(fd<0) { fail(@"independentOpen"); ok=NO; break; }
        struct stat *dst=[key isEqual:@"name"] ? target : decoy;
        ok=fstat(fd,dst)==0 && ok;
        BOOL read=markerRead(fd,c,[key isEqual:@"decoy"]); close(fd); ok=ok && read;
    }
    close(parent);
    ok=ok && !same(*target,*decoy);
    emit(@{@"event":@"originalIdentity",@"parent":ident(p),@"target":ident(*target),
           @"decoy":ident(*decoy),@"different":@(!same(*target,*decoy)),@"ok":@(ok),
           @"original":original(c),@"bytes":@([original(c) lengthOfBytesUsingEncoding:NSUTF8StringEncoding])});
    return ok;
}
static void fixture(NSDictionary *c) {
    int parent=parentFD(c,YES); if(parent<0) return;
    for(NSString *key in @[@"name",@"decoy"]) {
        const char *name=[c[key] UTF8String];
        if(directory(c) && mkdirat(parent,name,0700)) {fail(@"mkdirSubject");close(parent);return;}
        int fd=openat(parent,name,directory(c)?O_RDONLY|O_DIRECTORY|O_NOFOLLOW:O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0600);
        if(fd<0) {fail(@"createSubject");close(parent);return;}
        int writeFD=fd;
        if(directory(c)) writeFD=openat(fd,[c[@"child"] UTF8String],O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0600);
        NSData *d=[([key isEqual:@"name"]?c[@"marker"]:c[@"decoyMarker"]) dataUsingEncoding:NSUTF8StringEncoding];
        ssize_t n=writeFD<0?-1:write(writeFD,d.bytes,d.length);
        if(directory(c) && writeFD>=0) close(writeFD);
        close(fd);
        if(n!=(ssize_t)d.length) {fail(@"writeMarker");close(parent);return;}
    }
    close(parent);
    struct stat t={0},d={0}; BOOL ok=inspectOriginal(c,&t,&d);
    emit(@{@"event":@"fixture",@"ok":@(ok)});
}
static NSURL *operand(NSDictionary *c) {
    struct stat t={0},d={0}; if(!inspectOriginal(c,&t,&d)) return nil;
    NSString *path=[NSString stringWithFormat:@"/.vol/%llu/%llu",(unsigned long long)(unsigned int)t.st_dev,(unsigned long long)t.st_ino];
    int fd=open(path.UTF8String,O_RDONLY|O_NOFOLLOW|(directory(c)?O_DIRECTORY:0)); int saved=errno;
    struct stat got={0}; BOOL statOK=fd>=0 && fstat(fd,&got)==0;
    BOOL read=fd>=0 && markerRead(fd,c,NO);
    if(fd>=0) close(fd);
    BOOL ok=statOK && same(t,got) && !same(d,got) && read;
    emit(@{@"event":@"nativeIDControl",@"path":path,@"opened":@(fd>=0),@"errno":@(fd<0?saved:0),
           @"observed":ident(got),@"target":ident(t),@"matchesTarget":@(statOK&&same(t,got)),
           @"matchesDecoy":@(statOK&&same(d,got)),@"markerExact":@(read),@"ok":@(ok)});
    if(!ok) return nil;
    NSURL *u=[NSURL fileURLWithPath:path isDirectory:directory(c)];
    emit(@{@"event":@"pathURL",@"absoluteString":u.absoluteString,@"path":u.path,
           @"fileReference":@(u.isFileReferenceURL),@"hasBase":@(u.baseURL!=nil)});
    return u;
}
static NSURL *facts(NSURL *u) {
    for(NSURLResourceKey key in @[NSURLIsRegularFileKey,NSURLIsDirectoryKey,NSURLIsPackageKey,
                                 NSURLIsApplicationKey,NSURLIsAliasFileKey,NSURLIsExecutableKey,NSURLTypeIdentifierKey]) {
        id value=nil; NSError *e=nil; BOOL ok=[u getResourceValue:&value forKey:key error:&e];
        emit(@{@"event":@"nativeFact",@"key":key,@"success":@(ok),@"value":value?:[NSNull null],@"error":err(e)});
    }
    NSURL *app=[NSWorkspace.sharedWorkspace URLForApplicationToOpenURL:u];
    emit(@{@"event":@"handler",@"url":app.absoluteString?:[NSNull null],
           @"nilMeaning":@"unacquired; never established NO_DEFAULT_HANDLER"});
    return app;
}
static NSArray *nativeIdentity(NSURL *url) {
    NSURL *resolved=[url URLByResolvingSymlinksInPath];
    id volume=nil,file=nil; NSError *ve=nil,*fe=nil;
    BOOL v=resolved && [resolved getResourceValue:&volume forKey:NSURLVolumeIdentifierKey error:&ve];
    BOOL f=resolved && [resolved getResourceValue:&file forKey:NSURLFileResourceIdentifierKey error:&fe];
    emit(@{@"event":@"nativeExecutableIdentity",@"path":resolved.path?:@"",@"volumeOK":@(v),@"fileOK":@(f),
      @"volume":volume?[volume description]:@"",@"file":file?[file description]:@"",@"volumeError":err(ve),@"fileError":err(fe)});
    return v && f && volume && file ? @[volume,file] : nil;
}
static NSDictionary *receipt(pid_t pid, NSURL *callbackURL, NSRunningApplication *retained) {
    NSURL *selected=[[NSBundle bundleWithURL:[NSURL fileURLWithPath:@"/Applications/Zed.app"]] executableURL];
    char path[PROC_PIDPATHINFO_MAXSIZE]={0};
    struct proc_bsdinfo before={0},after={0};
    int n1=proc_pidinfo(pid,PROC_PIDTBSDINFO,0,&before,sizeof(before));
    int pathN=proc_pidpath(pid,path,sizeof(path)); int pathErr=errno;
    struct stat sel={0},live={0},cb={0};
    BOOL selectedOK=selected && stat(selected.fileSystemRepresentation,&sel)==0;
    BOOL liveOK=pathN>0 && stat(path,&live)==0;
    BOOL callbackOK=callbackURL && stat(callbackURL.fileSystemRepresentation,&cb)==0;
    NSArray *sn=nativeIdentity(selected),*ln=nativeIdentity(pathN>0?[NSURL fileURLWithPath:@(path)]:nil),*cn=nativeIdentity(callbackURL);
    int n2=proc_pidinfo(pid,PROC_PIDTBSDINFO,0,&after,sizeof(after));
    BOOL stable=n1==sizeof(before) && n2==sizeof(after) && before.pbi_start_tvsec==after.pbi_start_tvsec && before.pbi_start_tvusec==after.pbi_start_tvusec;
    NSTimeInterval deadline=NSProcessInfo.processInfo.systemUptime+0.25;
    BOOL freshEqual=NO;
    do {
        NSRunningApplication *fresh=[NSRunningApplication runningApplicationWithProcessIdentifier:pid];
        freshEqual=retained && fresh && [fresh isEqual:retained] && !fresh.isTerminated && fresh.processIdentifier==pid;
        if(freshEqual) break;
        usleep(5000);
    } while(NSProcessInfo.processInfo.systemUptime<deadline);
    BOOL retainedOK=retained && !retained.isTerminated && retained.processIdentifier==pid && pid>0;
    BOOL nativeEqual=sn && ln && cn && [sn isEqual:ln] && [sn isEqual:cn];
    BOOL exact=nativeEqual && freshEqual && retainedOK && stable && selectedOK && liveOK && callbackOK && same(sel,live) && same(sel,cb);
    NSDictionary *r=@{@"event":@"receipt",@"pid":@(pid),@"startSeconds":@(before.pbi_start_tvsec),@"startMicros":@(before.pbi_start_tvusec),
      @"stable":@(stable),@"nativeIdentityEqual":@(nativeEqual),@"freshLookupEqualsRetained":@(freshEqual),@"retainedAlive":@(retainedOK),@"selectedExecutable":selected.path?:@"",@"liveExecutable":pathN>0?@(path):@"",
      @"callbackExecutable":callbackURL.path?:@"",@"selectedIdentity":ident(sel),@"liveIdentity":ident(live),@"callbackIdentity":ident(cb),
      @"pathResult":@(pathN),@"pathErrno":@(pathN>0?0:pathErr),@"exact":@(exact)};
    emit(r);
    NSArray *windows=CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly,kCGNullWindowID));
    for(NSDictionary *w in windows) if([w[(id)kCGWindowOwnerPID] intValue]==pid)
        emit(@{@"event":@"ownedWindow",@"pid":@(pid),@"window":w});
    return r;
}
static void action(NSDictionary *c) {
    NSURL *u=operand(c); if(!u) {emit(@{@"event":@"incomplete",@"stage":@"identityControl"});return;}
    facts(u);
    NSURL *app=[NSURL fileURLWithPath:@"/Applications/Zed.app" isDirectory:YES];
    emit(@{@"event":@"submission",@"mode":@"named",@"operand":u.path,@"original":original(c),
      @"metadataDiagnosticBypass":@YES,@"deliveredOperand":@"opaque: no receiver instrumentation"});
    NSWorkspaceOpenConfiguration *config=NSWorkspaceOpenConfiguration.configuration;
    config.activates=YES;config.createsNewApplicationInstance=NO;config.allowsRunningApplicationSubstitution=NO;config.promptsUserIfNeeded=NO;
    NSTimeInterval start=NSProcessInfo.processInfo.systemUptime;
    __block BOOL completed=NO;
    [NSWorkspace.sharedWorkspace openURLs:@[u] withApplicationAtURL:app configuration:config completionHandler:^(NSRunningApplication *ra,NSError *e) {
        emit(@{@"event":@"callback",@"seconds":@(NSProcessInfo.processInfo.systemUptime-start),@"error":err(e),@"pid":ra?@(ra.processIdentifier):[NSNull null],
          @"bundleURL":ra.bundleURL.absoluteString?:@"",@"executableURL":ra.executableURL.absoluteString?:@"",@"selectedApp":app.path});
        if(ra) receipt(ra.processIdentifier,ra.executableURL,ra);
        completed=YES;
    }];
    while(!completed && NSProcessInfo.processInfo.systemUptime-start<3) [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    emit(@{@"event":@"request",@"callbackWithinThreeSeconds":@(completed),@"cancellation":completed?@"not required":@"helper exits; public request not retractable"});
    NSURL *after=operand(c); if(!after) emit(@{@"event":@"incomplete",@"stage":@"afterIdentity"});
}
int main(int argc,const char **argv) { @autoreleasepool {
    if(argc!=3) return 2;
    NSDictionary *c=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@(argv[2])] options:0 error:nil];
    if(!c) return 2;
    NSString *mode=@(argv[1]);
    if([mode isEqual:@"fixture"]) fixture(c);
    else if([mode isEqual:@"inspect"]) {NSURL *u=operand(c);if(u) facts(u);else emit(@{@"event":@"incomplete",@"stage":@"identityControl"});}
    else if([mode isEqual:@"incarnation"]) {
        receipt([c[@"pid"] intValue],[NSURL URLWithString:c[@"callbackExecutableURL"]],[NSRunningApplication runningApplicationWithProcessIdentifier:[c[@"pid"] intValue]]);
    } else if([mode isEqual:@"reset"] || [mode isEqual:@"running"]) {
        NSArray *apps=[NSRunningApplication runningApplicationsWithBundleIdentifier:@"dev.zed.Zed"];
        for(NSRunningApplication *app in apps) {
            emit(@{@"event":@"runningZed",@"pid":@(app.processIdentifier),@"bundleURL":app.bundleURL.path?:@""});
            if([mode isEqual:@"reset"]) emit(@{@"event":@"terminateReceiver",@"pid":@(app.processIdentifier),@"accepted":@([app terminate])});
        }
        emit(@{@"event":@"runningCount",@"count":@(apps.count)});
    } else if([mode isEqual:@"environment"]) {
        NSURL *known=[NSURL fileURLWithPath:@"/Applications/Zed.app" isDirectory:YES];
        NSURL *registered=[NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:@"dev.zed.Zed"];
        NSArray *ki=nativeIdentity(known),*ri=nativeIdentity(registered);
        struct stat ks={0},rs={0}; BOOL bundleExact=stat(known.fileSystemRepresentation,&ks)==0 && registered && stat(registered.fileSystemRepresentation,&rs)==0 && same(ks,rs) && ki && ri && [ki isEqual:ri];
        emit(@{@"event":@"zed",@"known":known.path,@"registered":registered.path?:[NSNull null],
               @"exact":@(bundleExact && [registered.path isEqual:known.path]),@"knownIdentity":ident(ks),@"registeredIdentity":ident(rs),
               @"registeredURLs":[[NSWorkspace.sharedWorkspace URLsForApplicationsWithBundleIdentifier:@"dev.zed.Zed"] valueForKey:@"path"]?:@[],
               @"version":[NSBundle bundleWithURL:known].infoDictionary[@"CFBundleShortVersionString"]?:[NSNull null]});
        struct attrlist a={0};a.bitmapcount=ATTR_BIT_MAP_COUNT;a.volattr=ATTR_VOL_CAPABILITIES;
        struct {uint32_t length;vol_capabilities_attr_t caps;} v={0};
        int rc=getattrlist("/Users/admin/k155",&a,&v,sizeof(v),0);
        emit(@{@"event":@"volume",@"status":@(rc),@"errno":@(rc?errno:0),
               @"capabilities":@[@(v.caps.capabilities[0]),@(v.caps.capabilities[1]),@(v.caps.capabilities[2]),@(v.caps.capabilities[3])],
               @"valid":@[@(v.caps.valid[0]),@(v.caps.valid[1]),@(v.caps.valid[2]),@(v.caps.valid[3])]});
    } else if([mode isEqual:@"named"]) action(c);
    else return 2;
    emit(@{@"event":@"done"});return 0;
} }
