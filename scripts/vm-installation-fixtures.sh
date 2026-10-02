#!/bin/bash
# Run IN THE GUEST (never on the host: it registers applications with Launch Services and
# launches nothing, but the registrations are the point and belong to a disposable VM).
# The reusable recipe for a registered application installed at several locations, used by
# docs/verification/application-installations-vm.md and by any increment that needs one
# bundle identifier on more than one installed copy (the search increment's constrained
# launch among them).
#
# usage: vm-installation-fixtures.sh <fixture source dir> <root>
#        vm-installation-fixtures.sh trash <root> <destination>
#
# The second form makes one more registered copy under its own identifier, waits for Launch
# Services to know it, and moves it to <destination> (the Trash), as the case about a registered
# present copy in the Trash needs it moved: Launch Services follows a move it was told of.
#
# It compiles Fixtures/InstallationFixture/main.swift once, then makes, under <root>, each
# copy as an ad-hoc-signed bundle (no quarantine, so Gatekeeper never assesses it) with its
# own Info.plist, and registers it with Launch Services unless the case is about a copy that
# is not registered:
#
#   multi    A/Fixture.app and B/Fixture.app, one identifier on two copies, both registered;
#            link-to-B (a link to B's folder) and link-to-B-app (a link to B's bundle)
#   unicode  <root>/Café/ (composed é, registered so) and <root>/Café ñ/ (decomposed,
#            registered so), one identifier each
#   stale    one copy, registered, then deleted (Launch Services drops the registration at once)
#   noplist  one copy, registered, whose Info.plist is then removed: the registration remains
#   unregistered  a present copy of its own identifier, registered and then unregistered
#   locked   one copy, registered, in a folder the caller then gives mode 000
#   anon     a bundle that declares no identifier, claiming the extension koineanon
#   bare     a program that is not a bundle
#   docs     the documents the open cases hand over
#
# A copy in the Trash is made by the caller moving `trashed` there: Launch Services keeps the
# registration of a bundle moved into the Trash and declines one made for a bundle already in it.
set -euo pipefail

if [ "$1" = trash ]; then
    MODE=trash
    ROOT="$2"
    DESTINATION="$3"
else
    MODE=build
    SOURCE="$1"
    ROOT="$2"
fi
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
BASE_ID="dev.koine.test.InstallationFixture"
BUILD="${ROOT}/.build"


# make_app <app path> <identifier or "-" for none> <copy label> [<document extension>]
make_app() {
    local app="$1" id="$2" label="$3" ext="${4:-koineinstall}" name
    name="$(basename "${app}" .app)"
    rm -rf "${app}"
    mkdir -p "${app}/Contents/MacOS"
    cp "${BUILD}/fixture-binary" "${app}/Contents/MacOS/${name}"
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
        echo '<plist version="1.0"><dict>'
        [ "${id}" = "-" ] || echo "  <key>CFBundleIdentifier</key><string>${id}</string>"
        echo "  <key>CFBundleName</key><string>${name}</string>"
        echo "  <key>CFBundleExecutable</key><string>${name}</string>"
        echo '  <key>CFBundlePackageType</key><string>APPL</string>'
        echo '  <key>CFBundleVersion</key><string>1</string>'
        echo '  <key>CFBundleShortVersionString</key><string>1.0</string>'
        echo '  <key>NSPrincipalClass</key><string>NSApplication</string>'
        echo "  <key>KoineCopyLabel</key><string>${label}</string>"
        # A Viewer of its own extension, never of an existing type, and never the default
        # for one that has another handler: the fixture is only ever named or the sole claimant.
        echo '  <key>CFBundleDocumentTypes</key><array><dict>'
        echo '    <key>CFBundleTypeName</key><string>Installation fixture document</string>'
        echo '    <key>CFBundleTypeRole</key><string>Viewer</string>'
        echo '    <key>LSHandlerRank</key><string>Alternate</string>'
        echo "    <key>CFBundleTypeExtensions</key><array><string>${ext}</string></array>"
        echo '  </dict></array>'
        echo '</dict></plist>'
    } >"${app}/Contents/Info.plist"
    codesign --force --sign - "${app}" >/dev/null 2>&1
}
register() { "${LSREGISTER}" -f "$1"; }

if [ "${MODE}" = trash ]; then
    mkdir -p "${ROOT}/trashed"
    make_app "${ROOT}/trashed/Fixture.app" "${BASE_ID}.Trashed" T
    register "${ROOT}/trashed/Fixture.app"
    sleep 3
    mv "${ROOT}/trashed/Fixture.app" "${DESTINATION}"
    exit 0
fi

mkdir -p "${BUILD}"
swiftc -O -swift-version 5 -o "${BUILD}/fixture-binary" "${SOURCE}/main.swift"
echo 'print("bare program")' >"${BUILD}/bare-program.swift"
swiftc -O -o "${BUILD}/bare-program" "${BUILD}/bare-program.swift"

# --- multi: one identifier, two registered copies, and two links ---------------------------
mkdir -p "${ROOT}/A" "${ROOT}/B"
make_app "${ROOT}/A/Fixture.app" "${BASE_ID}" A
make_app "${ROOT}/B/Fixture.app" "${BASE_ID}" B
register "${ROOT}/A/Fixture.app"
register "${ROOT}/B/Fixture.app"
ln -sfn "${ROOT}/B" "${ROOT}/link-to-B"
ln -sfn "${ROOT}/B/Fixture.app" "${ROOT}/link-to-B-app"

# --- unicode: the registered spelling and the spelling a client may send --------------------
COMPOSED="$(printf 'Caf\xc3\xa9')"
DECOMPOSED="$(printf 'Cafe\xcc\x81 \xc3\xb1')"
mkdir -p "${ROOT}/${COMPOSED}" "${ROOT}/${DECOMPOSED}"
make_app "${ROOT}/${COMPOSED}/Fixture.app" "${BASE_ID}.Composed" U1
make_app "${ROOT}/${DECOMPOSED}/Fixture.app" "${BASE_ID}.Decomposed" U2
register "${ROOT}/${COMPOSED}/Fixture.app"
register "${ROOT}/${DECOMPOSED}/Fixture.app"

# --- stale: registered, then deleted ----------------------------------------------------------
mkdir -p "${ROOT}/stale"
make_app "${ROOT}/stale/Fixture.app" "${BASE_ID}.Stale" S
register "${ROOT}/stale/Fixture.app"
rm -rf "${ROOT}/stale/Fixture.app"

# --- noplist: registered, then no longer an application ---------------------------------------
# Launch Services drops a registration the moment its bundle is deleted (observed), so this is
# the registration that stays: the bundle's folder is still there and its Info.plist is not.
mkdir -p "${ROOT}/noplist"
make_app "${ROOT}/noplist/Fixture.app" "${BASE_ID}.NoPlist" P
register "${ROOT}/noplist/Fixture.app"
sleep 2
rm "${ROOT}/noplist/Fixture.app/Contents/Info.plist"

# --- unregistered: present, with an identifier of its own, and unregistered ----------------------
# Launch Services registers a bundle it finds under the home folder on its own, so the copy is
# explicitly unregistered afterwards (the caller checks what the system answers).
mkdir -p "${ROOT}/unregistered"
make_app "${ROOT}/unregistered/Fixture.app" "${BASE_ID}.Unregistered" X
# It reports "failed to scan ... -10814" and exits nonzero for a bundle it then does unregister.
"${LSREGISTER}" -u "${ROOT}/unregistered/Fixture.app" || true

# --- locked: registered, then its folder made unreadable by `lock` ----------------------------
mkdir -p "${ROOT}/locked"
make_app "${ROOT}/locked/Fixture.app" "${BASE_ID}.Locked" L
register "${ROOT}/locked/Fixture.app"

# --- anon: no identifier, the sole claimant of koineanon ----------------------------------------
mkdir -p "${ROOT}/anon"
make_app "${ROOT}/anon/Anonymous.app" "-" ANON koineanon
register "${ROOT}/anon/Anonymous.app"

# --- bare: a program that is not a bundle -------------------------------------------------------
mkdir -p "${ROOT}/bare"
cp "${BUILD}/bare-program" "${ROOT}/bare/program"

# --- documents ----------------------------------------------------------------------------------
mkdir -p "${ROOT}/docs"
for name in note-1 note-2 note-3 note-4 note-5 note-6 note-7 note-8 note-9 note-10 note-11 note-12; do
    echo "${name}" >"${ROOT}/docs/${name}.koineinstall"
done
echo "anonymous" >"${ROOT}/docs/default-anon.koineanon"
echo "plain" >"${ROOT}/docs/plain.txt"

echo "fixtures ready under ${ROOT}"
