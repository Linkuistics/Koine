// Throwaway k149 diagnostic. Execute only in the authorized disposable guest.
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/stat.h>
#include <sys/attr.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

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
static NSString *urlText(CFURLRef u) {
    if (!u) return @"";
    NSString *s = (__bridge NSString *)CFURLGetString(u);
    if ([s lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 8192) {
        emit(@{@"event":@"incomplete", @"reason":@"URL text ceiling"}); exit(3);
    }
    return s;
}
static void logURL(NSString *stage, CFURLRef u, CFErrorRef e, NSUInteger bytes) {
    CFURLRef base = u ? CFURLGetBaseURL(u) : NULL; // borrowed, never retained
    emit(@{@"event":@"url", @"stage":stage, @"originalBytes":@(bytes),
           @"nonNull":@(u != NULL), @"reference":@(u && CFURLIsFileReferenceURL(u)),
           @"url":urlText(u), @"hasBase":@(base != NULL), @"base":urlText(base),
           @"error":err((__bridge NSError *)e)});
}
static CFURLRef pathURL(NSString *s, BOOL dir, CFURLRef base) {
    return CFURLCreateWithFileSystemPathRelativeToBase(NULL, (__bridge CFStringRef)s, kCFURLPOSIXPathStyle, dir, base);
}
static void convert(CFURLRef ref, NSString *original) {
    CFErrorRef e = NULL;
    CFURLRef p = CFURLCreateFilePathURL(NULL, ref, &e);
    logURL(@"pathConversion", p, e, [original lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    if (p) {
        CFStringRef s = CFURLCopyFileSystemPath(p, kCFURLPOSIXPathStyle);
        NSData *got = [(__bridge NSString *)s dataUsingEncoding:NSUTF8StringEncoding];
        emit(@{@"event":@"conversionBytes", @"exact":@([got isEqual:[original dataUsingEncoding:NSUTF8StringEncoding]]),
               @"bytes":@(got.length), @"pathB64":[got base64EncodedStringWithOptions:0] ?: @""});
        if (s) CFRelease(s); CFRelease(p);
    }
    if (e) CFRelease(e);
}
static BOOL consume(CFURLRef ref, struct stat target, struct stat decoy, NSString *marker) {
    NSError *e = nil;
    NSFileHandle *h = [NSFileHandle fileHandleForReadingFromURL:(__bridge NSURL *)ref error:&e];
    emit(@{@"event":@"consumerOpen", @"success":@(h != nil), @"error":err(e)});
    if (!h) return NO;
    struct stat observed = {0}; int rc = fstat(h.fileDescriptor, &observed); int saved = errno;
    emit(@{@"event":@"consumerIdentity", @"status":@(rc), @"errno":@(rc ? saved : 0),
           @"observed":ident(observed), @"matchesTarget":@(rc == 0 && same(observed,target)),
           @"matchesDecoy":@(rc == 0 && same(observed,decoy))});
    NSData *d = [h readDataUpToLength:64 error:&e];
    BOOL ok = rc == 0 && same(observed,target) && !same(observed,decoy) &&
              d && [d isEqual:[marker dataUsingEncoding:NSUTF8StringEncoding]];
    emit(@{@"event":@"consumerRead", @"markerExact":@(d && [d isEqual:[marker dataUsingEncoding:NSUTF8StringEncoding]]),
           @"bytes":@(d.length), @"error":err(e)});
    e = nil; BOOL closed = [h closeAndReturnError:&e];
    emit(@{@"event":@"consumerClose", @"success":@(closed), @"error":err(e)});
    return ok && closed;
}
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
static BOOL controls(NSDictionary *c, int fd, struct stat *target, struct stat *decoy) {
    int t=openat(fd,[c[@"name"] UTF8String],O_RDONLY|O_NOFOLLOW);
    if(t<0) { fail(@"independentTargetOpen"); return NO; }
    int rc=fstat(t,target); close(t);
    if(rc) { fail(@"independentTargetStat"); return NO; }
    int d=openat(fd,[c[@"decoy"] UTF8String],O_RDONLY|O_NOFOLLOW);
    if(d<0) { fail(@"independentDecoyOpen"); return NO; }
    rc=fstat(d,decoy); close(d);
    if(rc) { fail(@"independentDecoyStat"); return NO; }
    emit(@{@"event":@"independentIdentity", @"target":ident(*target), @"decoy":ident(*decoy), @"different":@(!same(*target,*decoy))});
    return !same(*target,*decoy);
}
static void fixture(NSDictionary *c) {
    int fd=parentFD(c,YES); if(fd<0) return;
    for(NSString *key in @[@"name",@"decoy"]) {
        int t=openat(fd,[c[key] UTF8String],O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0600);
        if(t<0) { fail(@"createFile"); close(fd); return; }
        NSData *d=[( [key isEqual:@"name"] ? c[@"marker"] : @"k149-decoy\n") dataUsingEncoding:NSUTF8StringEncoding];
        ssize_t n=write(t,d.bytes,d.length); close(t);
        if(n!=(ssize_t)d.length) { fail(@"writeMarker"); close(fd); return; }
    }
    int root=open([c[@"root"] UTF8String],O_RDONLY|O_DIRECTORY|O_NOFOLLOW);
    if(root<0) { fail(@"openRootLink"); close(fd); return; }
    int rc=linkat(fd,[c[@"name"] UTF8String],root,"same-object.txt",0); close(root);
    if(rc) { fail(@"shortSameObjectLink"); close(fd); return; }
    struct stat t={0},d={0}; BOOL ok=controls(c,fd,&t,&d); close(fd);
    emit(@{@"event":@"fixture", @"ok":@(ok), @"pathBytes":@([original(c) lengthOfBytesUsingEncoding:NSUTF8StringEncoding])});
}
static BOOL shortControl(NSDictionary *c,struct stat target,struct stat decoy) {
    NSString *p=[c[@"root"] stringByAppendingString:@"/same-object.txt"];
    // Independent short pathname construction, not a copy of the tested reference.
    CFURLRef u=pathURL(p,NO,NULL); CFErrorRef e=NULL;
    CFURLRef r=CFURLCreateFileReferenceURL(NULL,u,&e);
    logURL(@"shortReference",r,e,[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    CFRelease(u); if(e) CFRelease(e);
    BOOL ok=r && CFURLIsFileReferenceURL(r) && !CFURLGetBaseURL(r);
    if(ok) { ok=consume(r,target,decoy,c[@"marker"]); convert(r,p); }
    if(r) CFRelease(r);
    emit(@{@"event":@"shortControl", @"ok":@(ok)}); return ok;
}
static void runCase(NSDictionary *c,NSString *pattern) {
    int fd=parentFD(c,NO); if(fd<0) return;
    struct stat t={0},d={0};
    if(!controls(c,fd,&t,&d) || !shortControl(c,t,d)) { close(fd); emit(@{@"event":@"incomplete",@"reason":@"short/identity control"}); return; }
    NSString *whole=original(c); CFURLRef anchor=NULL; CFErrorRef e=NULL;
    if([pattern isEqual:@"direct"]) {
        CFURLRef u=pathURL(whole,NO,NULL); logURL(@"directInput",u,NULL,[whole lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        anchor=CFURLCreateFileReferenceURL(NULL,u,&e);
        logURL(@"directReference",anchor,e,[whole lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        CFRelease(u); if(e) {CFRelease(e);e=NULL;}
    } else {
        NSString *p=c[@"root"]; CFURLRef u=pathURL(p,YES,NULL);
        anchor=CFURLCreateFileReferenceURL(NULL,u,&e); CFRelease(u);
        logURL(@"rootReference",anchor,e,[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        if(e) {CFRelease(e);e=NULL;}
        NSArray *parts=[c[@"components"] arrayByAddingObject:c[@"name"]];
        for(NSUInteger i=0;i<parts.count;i++) {
            if(!anchor || !CFURLIsFileReferenceURL(anchor) || CFURLGetBaseURL(anchor)) break;
            p=[p stringByAppendingFormat:@"/%@",parts[i]];
            CFURLRef child=pathURL(parts[i],i+1<parts.count,anchor);
            logURL(@"relativeInput",child,NULL,[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            CFURLRef next=CFURLCreateFileReferenceURL(NULL,child,&e);
            // Exactly anchor + child + replacement. Borrowed strings/base URLs only.
            logURL(@"relativeReference",next,e,[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            CFRelease(child); CFRelease(anchor); anchor=next;
            if(e) {CFRelease(e);e=NULL;}
            if(!anchor || !CFURLIsFileReferenceURL(anchor) || CFURLGetBaseURL(anchor)) break;
        }
    }
    BOOL acquired=anchor && CFURLIsFileReferenceURL(anchor) && !CFURLGetBaseURL(anchor);
    if(anchor && CFURLGetBaseURL(anchor)) emit(@{@"event":@"incomplete",@"reason":@"returned reference base chain"});
    // A failed intermediate relative stage cannot masquerade as the final object:
    // identity and marker checks below remain independent even if an anchor survives.
    BOOL read=NO;
    if(acquired) { read=consume(anchor,t,d,c[@"marker"]); convert(anchor,whole); }
    emit(@{@"event":@"caseResult",@"pattern":pattern,@"acquired":@(acquired),@"localReadExact":@(read)});
    if(anchor) CFRelease(anchor); close(fd);
}
int main(int argc,const char **argv) { @autoreleasepool {
    if(argc!=3) return 2;
    NSData *data=[NSData dataWithContentsOfFile:@(argv[2])];
    NSDictionary *c=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if(!c) return 2;
    NSString *mode=@(argv[1]);
    if([mode isEqual:@"fixture"]) fixture(c);
    else if([mode isEqual:@"missing"]) {
        NSString *p=[c[@"root"] stringByAppendingString:@"/missing-name.txt"];
        CFURLRef u=pathURL(p,NO,NULL);CFErrorRef e=NULL;
        CFURLRef r=CFURLCreateFileReferenceURL(NULL,u,&e);
        logURL(@"missingReference",r,e,[p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        if(e) CFRelease(e); if(r) CFRelease(r); convert(u,p); CFRelease(u);
    } else if([mode isEqual:@"volume"]) {
        struct attrlist a={0}; a.bitmapcount=ATTR_BIT_MAP_COUNT;a.volattr=ATTR_VOL_CAPABILITIES;
        struct { uint32_t length; vol_capabilities_attr_t caps; } v={0};
        int rc=getattrlist([c[@"root"] UTF8String],&a,&v,sizeof(v),0);
        emit(@{@"event":@"volume",@"status":@(rc),@"errno":@(rc ? errno : 0),
               @"capabilities":@[@(v.caps.capabilities[0]),@(v.caps.capabilities[1]),@(v.caps.capabilities[2]),@(v.caps.capabilities[3])],
               @"valid":@[@(v.caps.valid[0]),@(v.caps.valid[1]),@(v.caps.valid[2]),@(v.caps.valid[3])]});
    } else runCase(c,mode);
    emit(@{@"event":@"done"}); return 0;
} }
