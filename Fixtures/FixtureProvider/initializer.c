// Evidence that this image's initializers ran. dylib initializers run inside
// dlopen, so a bundle the loader refuses beforehand must leave no line here.
// Appends this image's own path to the file KOINE_FIXTURE_INITIALIZER_LOG names.
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

__attribute__((constructor)) static void koine_fixture_initializer(void) {
    const char *log = getenv("KOINE_FIXTURE_INITIALIZER_LOG");
    Dl_info info;
    if (log == NULL || dladdr(&koine_fixture_initializer, &info) == 0) return;
    FILE *file = fopen(log, "a");
    if (file == NULL) return;
    fprintf(file, "%s\n", info.dli_fname);
    fclose(file);
}
