// Evidence that this image's code ran. dylib initializers run inside dlopen, so a
// bundle the loader refuses beforehand must leave no line here.
//
// Two logs, both appended to by the image's own code, each named by the
// environment:
//   KOINE_FIXTURE_INITIALIZER_LOG  this image's own path, one per initializer run
//   KOINE_FIXTURE_MARKER_LOG       `<phase>\t<image path>` for each phase the image
//                                  reaches: `initializer` here, then `factory` and
//                                  `start` from the provider (koine_image_marker),
//                                  so a selection acceptance run reads which images
//                                  ran which phases (scripts/verify-selection-decisions.py)
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

static void append(const char *variable, const char *phase, const char *image) {
    const char *log = getenv(variable);
    if (log == NULL) return;
    FILE *file = fopen(log, "a");
    if (file == NULL) return;
    if (phase != NULL) fprintf(file, "%s\t%s\n", phase, image);
    else fprintf(file, "%s\n", image);
    fclose(file);
}

// Called from the provider's factory and start: this image's own path is what
// dladdr finds for the function itself, so it names the image that ran.
__attribute__((visibility("hidden"))) void koine_image_marker(const char *phase) {
    Dl_info info;
    if (dladdr((const void *)&koine_image_marker, &info) == 0) return;
    append("KOINE_FIXTURE_MARKER_LOG", phase, info.dli_fname);
}

__attribute__((constructor)) static void koine_fixture_initializer(void) {
    Dl_info info;
    if (dladdr((const void *)&koine_fixture_initializer, &info) == 0) return;
    append("KOINE_FIXTURE_INITIALIZER_LOG", NULL, info.dli_fname);
    append("KOINE_FIXTURE_MARKER_LOG", "initializer", info.dli_fname);
}
