// k161-1: throwaway Foundation/CoreFoundation local-only diagnostic, execute solely in disposable guest.
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

static int ownedFDs=0, peakFDs=0;
static void emit(NSDictionary *row);
static void stop(NSString *stage) {
    emit(@{@"event":@"incomplete",@"stage":stage,@"errno":@(errno)});
    exit(3);
}
static void boundString(NSString *s) {
    if (![s isKindOfClass:NSString.class] || s.length>8192 ||
        [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>8192) stop(@"stringCapOrType");
}
static void logBounds(id v) {
    if ([v isKindOfClass:NSString.class]) boundString(v);
    else if ([v isKindOfClass:NSDictionary.class]) {
        for (id k in v) { boundString(k); logBounds(v[k]); }
    } else if ([v isKindOfClass:NSArray.class]) { for(id x in v) logBounds(x); }
    else if (![v isKindOfClass:NSNumber.class] && v!=NSNull.null) stop(@"unaccountedLogValue");
}
static void emit(NSDictionary *row) {
    logBounds(row);
    NSError *e=nil;
    NSData *d=[NSJSONSerialization dataWithJSONObject:row options:0 error:&e];
    if(!d || d.length>131072) { fprintf(stderr,"JSON observer failure\n"); exit(3); }
    if(fwrite(d.bytes,1,d.length,stdout)!=d.length || fputc('\n',stdout)==EOF || fflush(stdout)) exit(3);
}
static int track(int fd) {
    if(fd>=0) { ownedFDs++; if(ownedFDs>peakFDs) peakFDs=ownedFDs; if(ownedFDs>3) stop(@"descriptorCap"); }
    return fd;
}
static void shut(int fd) { if(fd>=0) { if(close(fd)) stop(@"close"); ownedFDs--; } }
static NSDictionary *identity(struct stat s) {
    return @{@"device":@((long long)s.st_dev),@"inode":@((unsigned long long)s.st_ino),@"mode":@(s.st_mode)};
}
static BOOL same(struct stat a,struct stat b) { return a.st_dev==b.st_dev && a.st_ino==b.st_ino; }
static NSArray *errors(NSError *e) {
    NSMutableArray *r=[NSMutableArray array];
    for(NSUInteger n=0;e;n++) {
        if(n>=8 || ![e isKindOfClass:NSError.class]) stop(@"unaccountedErrorChain");
        boundString(e.domain);
        [r addObject:@{@"type":NSStringFromClass(e.class),@"domain":e.domain,@"code":@(e.code)}];
        e=e.userInfo[NSUnderlyingErrorKey];
    }
    return r;
}
static NSString *original(NSDictionary *c) {
    NSString *p=c[@"root"];
    for(NSString *part in c[@"components"]) p=[p stringByAppendingFormat:@"/%@",part];
    p=[p stringByAppendingFormat:@"/%@",c[@"name"]]; boundString(p);
    if([p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]!=[c[@"bytes"] unsignedIntegerValue]) stop(@"fixtureLength");
    return p;
}
static int parent(NSDictionary *c,BOOL create) {
    NSString *root=c[@"root"]; boundString(root);
    if(create && mkdir(root.UTF8String,0700)) stop(@"mkdirRoot");
    int fd=track(open(root.UTF8String,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC));
    if(fd<0) stop(@"openRoot");
    NSArray *parts=c[@"components"];
    if(parts.count+1>32) stop(@"componentDepth");
    for(NSString *p in parts) {
        boundString(p);
        if(!p.length || [p lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>245 ||
           [p containsString:@"/"] || [p isEqual:@"."] || [p isEqual:@".."]) stop(@"componentCap");
        if(create && mkdirat(fd,p.UTF8String,0700)) stop(@"mkdirat");
        int next=track(openat(fd,p.UTF8String,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC));
        if(next<0) stop(@"openatParent");
        shut(fd); fd=next;
    }
    return fd;
}
static BOOL marker(int fd,NSString *want,NSString *label) {
    boundString(want);
    NSUInteger count=[want lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(count>64) stop(@"markerCap");
    char b[64]; ssize_t n=read(fd,b,sizeof(b)); int saved=errno;
    BOOL exact=n==(ssize_t)count && !memcmp(b,want.UTF8String,count);
    emit(@{@"event":@"controlMarker",@"label":label,@"bytes":@(n),@"errno":@(n<0?saved:0),
           @"b64":n>=0?[[NSData dataWithBytes:b length:(NSUInteger)n] base64EncodedStringWithOptions:0]:@"",@"exact":@(exact)});
    return exact;
}
static NSString *bare(struct stat s) {
    return [NSString stringWithFormat:@"/.vol/%llu/%llu",(unsigned long long)(unsigned int)s.st_dev,(unsigned long long)s.st_ino];
}
static void controls(NSDictionary *c,NSString *phase,struct stat *t,struct stat *d,struct stat *p) {
    int pd=parent(c,NO); if(fstat(pd,p)) stop(@"statParent");
    if(!S_ISDIR(p->st_mode)) stop(@"parentType");
    for(NSString *key in @[@"name",@"decoy"]) {
        boundString(c[key]);
        int fd=track(openat(pd,[c[key] UTF8String],O_RDONLY|O_NOFOLLOW|O_CLOEXEC));
        if(fd<0) stop(@"originalControlOpen");
        if(fstat(fd,[key isEqual:@"name"]?t:d)) stop(@"originalControlStat");
        BOOL ok=marker(fd,c[[key isEqual:@"name"]?@"marker":@"decoyMarker"],key);
        shut(fd); if(!ok) stop(@"originalControlMarker");
    }
    shut(pd);
    if(same(*t,*d) || !S_ISREG(t->st_mode) || !S_ISREG(d->st_mode)) stop(@"originalControlIdentity");
    NSString *parentAddress=[bare(*p) stringByAppendingString:@"/"];
    int pfd=track(open(parentAddress.UTF8String,O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC));
    if(pfd<0) stop(@"bareParentControlOpen");
    struct stat bp={0}; if(fstat(pfd,&bp)) stop(@"bareParentControlStat"); shut(pfd);
    if(!same(*p,bp)||!S_ISDIR(bp.st_mode)) stop(@"bareParentControlIdentity");
    NSString *address=bare(*t);
    int fd=track(open(address.UTF8String,O_RDONLY|O_NOFOLLOW|O_CLOEXEC));
    if(fd<0) stop(@"bareControlOpen");
    struct stat b={0}; if(fstat(fd,&b)) stop(@"bareControlStat");
    BOOL ok=marker(fd,c[@"marker"],@"bare"); shut(fd);
    if(!same(*t,b) || same(*d,b) || !ok) stop(@"bareControlIdentity");
    emit(@{@"event":@"controls",@"phase":phase,@"ok":@YES,@"parent":identity(*p),
           @"target":identity(*t),@"decoy":identity(*d),@"bare":identity(b),@"barePath":address,
           @"bareParent":identity(bp),@"bareParentPath":parentAddress,@"original":original(c)});
}
static void fixture(NSDictionary *c) {
    int pd=parent(c,YES);
    for(NSString *key in @[@"name",@"decoy"]) {
        boundString(c[key]);
        int fd=track(openat(pd,[c[key] UTF8String],O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW|O_CLOEXEC,0600));
        if(fd<0) stop(@"createFile");
        NSString *m=c[[key isEqual:@"name"]?@"marker":@"decoyMarker"]; boundString(m);
        NSUInteger n=[m lengthOfBytesUsingEncoding:NSUTF8StringEncoding]; if(n>64) stop(@"markerCap");
        if(write(fd,m.UTF8String,n)!=(ssize_t)n) stop(@"writeMarker"); shut(fd);
    }
    shut(pd);
    struct stat t={0},d={0},p={0}; controls(c,@"fixture",&t,&d,&p);
    emit(@{@"event":@"fixture",@"ok":@YES,@"bytes":c[@"bytes"]});
}
static id storedValue(id v) {
    if(!v) return @{@"present":@NO};
    if(![v isKindOfClass:NSString.class]) stop(@"storedValueType");
    boundString(v);
    return @{@"present":@YES,@"type":NSStringFromClass([v class]),@"value":v,
             @"utf8Bytes":@([v lengthOfBytesUsingEncoding:NSUTF8StringEncoding])};
}
static NSDictionary *textName(NSString *text,NSString *want);
static void measureBookmark(NSDictionary *c,NSString *mode,struct stat t,struct stat d) {
    NSString *path=original(c),*input=[mode isEqual:@"original"]?path:bare(t); boundString(input);
    NSURL *operand=[NSURL fileURLWithPath:input isDirectory:NO];
    if(!operand) stop(@"operandURL");
    emit(@{@"event":@"inputURL",@"spelling":operand.absoluteString,@"input":input,
           @"basePresent":@(operand.baseURL!=nil),@"fileReference":@(operand.isFileReferenceURL)});
    NSError *creationError=nil;
    NSData *bookmark=[operand bookmarkDataWithOptions:NSURLBookmarkCreationWithoutImplicitSecurityScope
        includingResourceValuesForKeys:@[NSURLNameKey,NSURLPathKey] relativeToURL:nil error:&creationError];
    emit(@{@"event":@"creation",@"nonNull":@(bookmark!=nil),@"bytes":@(bookmark.length),@"errors":errors(creationError)});
    if(!bookmark) {
        emit(@{@"event":@"caseResult",@"storedName":@"unrun",@"resolution":@"unrun",@"read":@"unrun",@"firstFailure":@"creation"});
        return;
    }
    if(bookmark.length>65536) stop(@"bookmarkCap");
    // Preserve the one NSData directly, avoiding an oversized base64 log or second bookmark copy.
    NSString *rawPath=[NSString stringWithFormat:@"/tmp/k161-%@-%@.bookmark",mode,c[@"bytes"]];
    int rawFD=track(open(rawPath.UTF8String,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW|O_CLOEXEC,0600));
    if(rawFD<0 || write(rawFD,bookmark.bytes,bookmark.length)!=(ssize_t)bookmark.length) stop(@"bookmarkEvidenceWrite");
    shut(rawFD);
    emit(@{@"event":@"bookmarkData",@"bytes":@(bookmark.length),@"rawFile":rawPath});
    NSDictionary *values=[NSURL resourceValuesForKeys:@[NSURLNameKey,NSURLPathKey] fromBookmarkData:bookmark];
    if(values && (![values isKindOfClass:NSDictionary.class] || values.count>2)) stop(@"storedDictionaryShape");
    for(id key in values) if(![key isEqual:NSURLNameKey] && ![key isEqual:NSURLPathKey]) stop(@"unaccountedStoredKey");
    id name=values[NSURLNameKey],storedPath=values[NSURLPathKey];
    id nameRecord=storedValue(name),pathRecord=storedValue(storedPath);
    BOOL nameExact=[name isEqual:c[@"name"]],pathExact=[storedPath isEqual:path];
    emit(@{@"event":@"storedProperties",@"dictionaryPresent":@(values!=nil),@"name":nameRecord,@"path":pathRecord,
           @"originalNameExact":@(nameExact),@"originalPathExact":@(pathExact)});
    NSError *resolutionError=nil; BOOL stale=NO;
    NSURL *resolved=[NSURL URLByResolvingBookmarkData:bookmark
        options:NSURLBookmarkResolutionWithoutUI|NSURLBookmarkResolutionWithoutMounting|NSURLBookmarkResolutionWithoutImplicitStartAccessing
        relativeToURL:nil bookmarkDataIsStale:&stale error:&resolutionError];
    emit(@{@"event":@"resolution",@"nonNull":@(resolved!=nil),@"stale":@(stale),@"errors":errors(resolutionError)});
    if(!resolved) {
        emit(@{@"event":@"caseResult",@"storedName":@(nameExact),@"resolution":@NO,@"read":@"unrun",@"firstFailure":nameExact?@"resolution":@"storedName"});
        return;
    }
    NSURL *base=resolved.baseURL;
    NSString *spelling=resolved.absoluteString; boundString(spelling);
    emit(@{@"event":@"resolvedURL",@"spelling":spelling,@"fileURL":@(resolved.isFileURL),
           @"fileReference":@(resolved.isFileReferenceURL),@"basePresent":@(base!=nil),@"baseSpelling":base.absoluteString?:NSNull.null});
    if(base || !resolved.isFileURL) stop(@"nonFileOrBaseChain");
    base=nil;
    NSString *returnedPath=resolved.path; // Exactly one path extraction from the returned NSURL.
    if(!returnedPath) {
        emit(@{@"event":@"pathExtraction",@"success":@NO,@"reason":@"nil path"});
        emit(@{@"event":@"caseResult",@"storedName":@(nameExact),@"resolution":@YES,@"read":@NO,@"firstFailure":@"pathExtraction"});
        return;
    }
    boundString(returnedPath);
    NSUInteger size=[returnedPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *utf8=returnedPath.UTF8String; // Exactly one UTF-8 extraction; copy only after size check.
    if(!utf8 || strlen(utf8)!=size) stop(@"unusablePathEncoding");
    emit(@{@"event":@"pathExtraction",@"success":@YES,@"utf8Bytes":@(size),@"path":returnedPath,
           @"b64":[[NSData dataWithBytes:utf8 length:size] base64EncodedStringWithOptions:0],
           @"originalPathExact":@([returnedPath isEqual:path]),@"finalBasename":returnedPath.lastPathComponent,
           @"originalNameExact":@([returnedPath.lastPathComponent isEqual:c[@"name"]])});
    int fd=track(open(utf8,O_RDONLY|O_NOFOLLOW|O_CLOEXEC)); int openError=errno;
    emit(@{@"event":@"wholePathOpen",@"success":@(fd>=0),@"errno":@(fd<0?openError:0)});
    BOOL readOK=NO; NSString *readFailure=fd<0?@"wholePathOpen":nil;
    if(fd>=0) {
        struct stat got={0}; int status=fstat(fd,&got),statError=errno;
        emit(@{@"event":@"wholePathStat",@"success":@(status==0),@"errno":@(status?statError:0),
               @"identity":identity(got),@"matchesOriginal":@(status==0&&same(t,got)),@"matchesDecoy":@(status==0&&same(d,got))});
        if(status) readFailure=@"wholePathStat";
        if(!status) {
            char b[64]; ssize_t n=read(fd,b,sizeof(b)); int readError=errno;
            NSString *m=c[@"marker"]; NSUInteger expected=[m lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            BOOL markerExact=n==(ssize_t)expected && !memcmp(b,m.UTF8String,expected);
            readOK=same(t,got)&&!same(d,got)&&markerExact;
            if(!readOK) readFailure=n<0?@"wholePathRead":@"wholePathIdentityMarker";
            emit(@{@"event":@"wholePathRead",@"bytes":@(n),@"errno":@(n<0?readError:0),@"markerExact":@(markerExact),
                   @"b64":n>=0?[[NSData dataWithBytes:b length:(NSUInteger)n] base64EncodedStringWithOptions:0]:@"",@"sameObjectRead":@(readOK)});
        }
        shut(fd);
    }
    emit(@{@"event":@"caseResult",@"storedName":@(nameExact),@"storedPath":@(pathExact),@"resolution":@YES,
           @"read":@(readOK),@"firstFailure":!nameExact?@"storedName":!readOK?readFailure:NSNull.null});
    resolved=nil; operand=nil; bookmark=nil;
}
// Text only: no URL parser, name getter or resource lookup in either observation.
static int hexByte(unsigned char x) {
    if(x>='0'&&x<='9') return x-'0';
    if(x>='a'&&x<='f') return x-'a'+10;
    if(x>='A'&&x<='F') return x-'A'+10;
    return -1;
}
static NSDictionary *textName(NSString *text,NSString *want) {
    boundString(text); boundString(want);
    const unsigned char *s=(const unsigned char *)text.UTF8String;
    if(!s) return @{@"acquired":@NO,@"reason":@"encoding"};
    size_t n=strlen((const char *)s),start=0;
    if(n!=[text lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
        return @{@"acquired":@NO,@"reason":@"embeddedNUL"};
    if(n>=7&&!memcmp(s,"file://",7)) {
        start=7;
        while(start<n&&s[start]!='/') start++;
        if(start==n) return @{@"acquired":@NO,@"reason":@"missingFilePath"};
    } else {
        for(size_t i=0;i<n;i++) if(s[i]==':')
            return @{@"acquired":@NO,@"reason":@"unsupportedScheme"};
    }
    for(size_t i=start;i<n;i++) {
        if(s[i]=='?'||s[i]=='#') return @{@"acquired":@NO,@"reason":@"queryOrFragment"};
        if(s[i]=='/') start=i+1;
    }
    if(start>=n) return @{@"acquired":@NO,@"reason":@"emptyName"};
    unsigned char decoded[8192]; size_t count=0;
    for(size_t i=start;i<n;i++) {
        unsigned char v=s[i];
        if(v=='%') {
            if(i+2>=n||hexByte(s[i+1])<0||hexByte(s[i+2])<0)
                return @{@"acquired":@NO,@"reason":@"malformedEscape"};
            v=(unsigned char)((hexByte(s[i+1])<<4)|hexByte(s[i+2])); i+=2;
        }
        if(!v||v=='/') return @{@"acquired":@NO,@"reason":@"invalidDecodedComponent"};
        decoded[count++]=v;
    }
    NSUInteger expected=[want lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    return @{@"acquired":@YES,@"bytes":@(count),
        @"b64":[[NSData dataWithBytes:decoded length:count] base64EncodedStringWithOptions:0],
        @"originalNameExact":@(count==expected&&!memcmp(decoded,want.UTF8String,count))};
}
static void parentResult(id relativeName,id absoluteName,id read,id failure) {
    emit(@{@"event":@"caseResult",@"relativeName":relativeName,@"absoluteName":absoluteName,
        @"read":read,@"firstFailure":failure?:NSNull.null});
}
static void measureParent(NSDictionary *c,NSString *mode,struct stat t,struct stat d,struct stat p) {
    NSString *address=[bare(p) stringByAppendingString:@"/"]; boundString(address);
    NSURL *operand=[NSURL fileURLWithPath:address isDirectory:YES];
    if(!operand||operand.baseURL||!operand.isFileURL||!operand.hasDirectoryPath) stop(@"parentOperandShape");
    emit(@{@"event":@"parentOperand",@"path":address,@"spelling":operand.absoluteString,
        @"basePresent":@NO,@"fileReference":@(operand.isFileReferenceURL),@"directory":@(operand.hasDirectoryPath)});
    NSURL *base=nil;
    if([mode isEqual:@"parent-public"]) {
        CFErrorRef cfError=NULL;
        CFURLRef acquired=CFURLCreateFileReferenceURL(kCFAllocatorDefault,(__bridge CFURLRef)operand,&cfError);
        base=CFBridgingRelease(acquired);
        NSError *error=CFBridgingRelease(cfError);
        emit(@{@"event":@"parentAcquisition",@"nonNull":@(base!=nil),@"errors":errors(error)});
        if(!base||error) { parentResult(@"unrun",@"unrun",@"unrun",@"parentAcquisition"); return; }
        if(base.baseURL||!base.isFileURL||!base.isFileReferenceURL||!base.hasDirectoryPath)
            stop(@"publicParentShape");
        operand=nil;
    } else { base=operand; operand=nil; }
    NSString *baseText=base.absoluteString; boundString(baseText);
    emit(@{@"event":@"parentBase",@"spelling":baseText,@"basePresent":@NO,
        @"fileURL":@(base.isFileURL),@"fileReference":@(base.isFileReferenceURL),
        @"directory":@(base.hasDirectoryPath),@"trailingSlash":@([baseText hasSuffix:@"/"])});
    NSURL *relative=[NSURL fileURLWithPath:c[@"name"] isDirectory:NO relativeToURL:base];
    emit(@{@"event":@"relativeConstruction",@"nonNull":@(relative!=nil)});
    if(!relative) { parentResult(@"unrun",@"unrun",@"unrun",@"relativeConstruction"); return; }
    // The borrowed relationship does not acquire another NSURL owner.
    BOOL basePresent=relative.baseURL!=nil,baseIdentical=relative.baseURL==base;
    if(!relative.isFileURL||relative.hasDirectoryPath||(basePresent&&!baseIdentical)) stop(@"relativeShape");
    NSString *relativeText=relative.relativeString; boundString(relativeText);
    NSDictionary *relativeName=textName(relativeText,c[@"name"]);
    emit(@{@"event":@"relativeURL",@"relativeSpelling":relativeText,
        @"fileURL":@(relative.isFileURL),@"fileReference":@(relative.isFileReferenceURL),
        @"directory":@(relative.hasDirectoryPath),@"basePresent":@(basePresent),
        @"baseIdentical":@(baseIdentical),@"name":relativeName});
    NSString *firstFailure=![relativeName[@"acquired"] boolValue]?@"relativeNameUnacquired":
        ![relativeName[@"originalNameExact"] boolValue]?@"relativeName":nil;
    NSURL *absolute=relative.absoluteURL; // Once, after recorded relative spelling.
    emit(@{@"event":@"absoluteResolution",@"nonNull":@(absolute!=nil),@"aliasesRelative":@(absolute==relative)});
    if(!absolute) { parentResult(relativeName,@"unrun",@"unrun",firstFailure?:@"absoluteResolution"); return; }
    if(absolute.baseURL||!absolute.isFileURL||absolute.hasDirectoryPath) stop(@"absoluteShape");
    NSString *absoluteText=absolute.absoluteString; boundString(absoluteText);
    NSDictionary *absoluteName=textName(absoluteText,c[@"name"]);
    if(!firstFailure) firstFailure=![absoluteName[@"acquired"] boolValue]?@"absoluteNameUnacquired":
        ![absoluteName[@"originalNameExact"] boolValue]?@"absoluteName":nil;
    emit(@{@"event":@"absoluteURL",@"spelling":absoluteText,@"basePresent":@NO,
        @"fileURL":@(absolute.isFileURL),@"fileReference":@(absolute.isFileReferenceURL),
        @"name":absoluteName,@"urlDistinctMaximum":@(absolute==relative?2:3)});
    NSString *path=absolute.path; // Once. No content reader or conversion fallback.
    if(!path) { parentResult(relativeName,absoluteName,@"unrun",firstFailure?:@"pathExtraction"); return; }
    boundString(path); NSUInteger size=[path lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *utf8=path.UTF8String;
    if(!utf8||strlen(utf8)!=size) stop(@"unusablePathEncoding");
    emit(@{@"event":@"pathExtraction",@"success":@YES,@"path":path,@"utf8Bytes":@(size),
        @"b64":[[NSData dataWithBytes:utf8 length:size] base64EncodedStringWithOptions:0],
        @"originalPathExact":@([path isEqual:original(c)])});
    int fd=track(open(utf8,O_RDONLY|O_NOFOLLOW|O_CLOEXEC)),saved=errno;
    emit(@{@"event":@"wholePathOpen",@"success":@(fd>=0),@"errno":@(fd<0?saved:0)});
    BOOL readOK=NO;
    if(fd<0) { if(!firstFailure) firstFailure=@"wholePathOpen"; }
    else {
        struct stat got={0}; int status=fstat(fd,&got); saved=errno;
        emit(@{@"event":@"wholePathStat",@"success":@(status==0),@"errno":@(status?saved:0),
            @"identity":identity(got),@"matchesOriginal":@(status==0&&same(t,got)),
            @"matchesDecoy":@(status==0&&same(d,got))});
        if(status) { if(!firstFailure) firstFailure=@"wholePathStat"; }
        else {
            char b[64]; ssize_t n=read(fd,b,sizeof(b)); saved=errno;
            NSString *want=c[@"marker"]; NSUInteger expected=[want lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            BOOL exact=n==(ssize_t)expected&&!memcmp(b,want.UTF8String,expected);
            readOK=same(t,got)&&!same(d,got)&&exact;
            emit(@{@"event":@"wholePathRead",@"bytes":@(n),@"errno":@(n<0?saved:0),@"markerExact":@(exact),
                @"b64":n>=0?[[NSData dataWithBytes:b length:(NSUInteger)n] base64EncodedStringWithOptions:0]:@"",
                @"sameObjectRead":@(readOK)});
            if(!readOK&&!firstFailure) firstFailure=n<0?@"wholePathRead":@"wholePathIdentityMarker";
        }
        shut(fd);
    }
    parentResult(relativeName,absoluteName,@(readOK),firstFailure);
    absolute=nil; relative=nil; base=nil; operand=nil;
}
int main(int argc,const char **argv) { @autoreleasepool {
    if(argc!=3) return 2;
    NSError *e=nil;
    NSDictionary *c=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@(argv[2])] options:0 error:&e];
    if(![c isKindOfClass:NSDictionary.class]) return 2;
    NSString *mode=@(argv[1]);
    original(c);
    if([mode isEqual:@"fixture"]) fixture(c);
    else if([mode isEqual:@"original"] || [mode isEqual:@"bare"]) {
        struct stat t={0},d={0},p={0},at={0},ad={0},ap={0};
        controls(c,@"before",&t,&d,&p);
        @autoreleasepool { measureBookmark(c,mode,t,d); }
        controls(c,@"after",&at,&ad,&ap);
        if(!same(t,at)||!same(d,ad)||!same(p,ap)) stop(@"changedControl");
    } else if([mode isEqual:@"parent-public"]||[mode isEqual:@"parent-bare"]) {
        struct stat t={0},d={0},p={0},at={0},ad={0},ap={0};
        controls(c,@"before",&t,&d,&p);
        @autoreleasepool { measureParent(c,mode,t,d,p); }
        controls(c,@"after",&at,&ad,&ap);
        if(!same(t,at)||!same(d,ad)||!same(p,ap)) stop(@"changedControl");
    } else return 2;
    if(ownedFDs) stop(@"descriptorLeak");
    emit(@{@"event":@"done",@"mode":mode,@"descriptorPeak":@(peakFDs),@"descriptorsRemaining":@(ownedFDs),
           @"urlLexicalMaximum":@4,@"externalRequests":@0});
    return 0;
} }
