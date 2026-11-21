"""Checked guest exec reads for the Settings harness.

Each read has one fixed guest command, an exact grammar for its stdout and a
parsed record. The tagged agent runs a command with `/bin/bash -c` and strips
trailing whitespace from stdout, so no grammar ends in a newline.
https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift

A negative domain fact is a complete payload, never a failed command. The
evidence class admits a read only when the read changes no guest state.
"""

# pyright: strict
from __future__ import annotations

import json
import plistlib
import re
from collections.abc import Callable
from dataclasses import dataclass
from typing import cast
from xml.parsers.expat import ExpatError

INSTALLED = "/Applications/Koine.app"
# The legacy helpers quote this path in double quotes, so the guest expands it.
DESCRIPTOR = '"$HOME/Library/Application Support/Koine/endpoint.json"'
DOMAIN = "dev.antony.Koine"
DIAGNOSTIC_KEYS = (
    "KoineSettingsActivationTrace",
    "KoineSettingsEventBuffer",
    "KoineSettingsMenuProbe",
)
# The two legacy pgrep patterns: expect_stopped and quit_koine use the first,
# and the login check uses the second.
PROCESS_PATTERNS = {
    "executable": f"{INSTALLED}/Contents/MacOS",
    "bundle": INSTALLED,
    # The one absence read after the TextEdit quit.
    "textedit": "/System/Applications/TextEdit.app/Contents/MacOS",
}
MANAGED = "/Library/Managed Preferences"
# The four any-user domains of the standard search list, after the four
# current-user domains: this application, then the global domain, each for
# the current host (/Library/Preferences) and for any host (its Network
# directory). `defaults` addresses each one by its path.
# https://github.com/apple-oss-distributions/CF/blob/main/CFApplicationPreferences.c#L391-L436
# https://github.com/apple-oss-distributions/CF/blob/main/CFPreferences.c#L181-L512
ANY_USER = (
    f"/Library/Preferences/{DOMAIN}",
    f"/Library/Preferences/Network/{DOMAIN}",
    "/Library/Preferences/.GlobalPreferences",
    "/Library/Preferences/Network/.GlobalPreferences",
)


class ReadError(ValueError):
    """The stdout does not match the exact grammar of its read."""


def lines(stdout: str) -> list[str]:
    if stdout != stdout.rstrip():
        raise ReadError("stdout keeps trailing whitespace that the agent strips")
    return stdout.split("\n")


def unique_object(pairs: list[tuple[str, object]]) -> dict[str, object]:
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise ReadError(f"duplicate JSON field: {key}")
        result[key] = value
    return result


def reject_constant(value: str) -> object:
    raise ReadError(f"non-JSON numeric constant: {value}")


def integer(value: object) -> bool:
    return type(value) is int


# --- endpoint -------------------------------------------------------------


def endpoint_command(_: list[str]) -> str:
    return (
        f'f={DESCRIPTOR}; if [ -e "$f" ]; then printf \'PRESENT\\n\'; cat "$f"; '
        "else printf 'ABSENT'; fi"
    )


def endpoint_parse(stdout: str, _: list[str]) -> dict[str, object]:
    if stdout == "ABSENT":
        return {"present": False}
    head, separator, body = stdout.partition("\n")
    if head != "PRESENT" or not separator:
        raise ReadError("expected ABSENT or PRESENT and the descriptor")
    lines(stdout)
    return {"present": True, "descriptor": descriptor_fields(body)}


def descriptor_fields(body: str) -> dict[str, object]:
    try:
        value: object = json.loads(
            body, object_pairs_hook=unique_object, parse_constant=reject_constant
        )
    except json.JSONDecodeError as error:
        raise ReadError(f"descriptor is not one JSON object: {error}") from None
    if not isinstance(value, dict):
        raise ReadError("descriptor is not one JSON object")
    descriptor = cast(dict[str, object], value)
    # Sources/KoineServer/EndpointDescriptor.swift owns these fields.
    keys = ["contractVersion", "descriptorVersion", "instanceId", "path", "pid", "port"]
    pid, port = descriptor.get("pid"), descriptor.get("port")
    if not (
        sorted(descriptor) == keys
        and descriptor["descriptorVersion"] == 1
        and integer(descriptor["descriptorVersion"])
        and isinstance(descriptor["instanceId"], str)
        and descriptor["instanceId"] != ""
        and descriptor["path"] == "/graphql"
        and integer(pid)
        and cast(int, pid) > 0
        and integer(port)
        and 0 < cast(int, port) <= 65535
        and isinstance(descriptor["contractVersion"], str)
        and descriptor["contractVersion"] != ""
    ):
        raise ReadError("descriptor fields differ from the version-1 schema")
    return descriptor


# --- process --------------------------------------------------------------


def process_command(arguments: list[str]) -> str:
    pattern = PROCESS_PATTERNS[arguments[0]]
    # pgrep exits 1 for no match, which becomes the complete payload NONE.
    # By default pgrep excludes its ancestors, so the bash wrapper never
    # matches its own pattern (pgrep(1), "-a").
    # With several PIDs, ps keeps each selected process that still exists and
    # exits 1 only when none remains. The command therefore prints the
    # selection, and the parser compares each ps block with it.
    # https://github.com/apple-oss-distributions/adv_cmds/blob/main/ps/ps.c
    # Both blocks print the start time, so each row pair joins on PID and start.
    # The comm column is argv[0], which the process sets, and not the saved
    # executable path that ps skips (print.c, getproclline).
    # https://github.com/apple-oss-distributions/adv_cmds/blob/main/ps/print.c
    return (
        f"p=$(pgrep -f '{pattern}'); s=$?; if [ \"$s\" = 1 ]; then printf 'NONE'; "
        "elif [ \"$s\" = 0 ]; then l=$(printf '%s' \"$p\" | tr '\\n' ,); "
        "printf 'KOINE-SELECTED %s\\n' \"$l\" && "
        "LC_ALL=C ps -ww -o pid=,lstart=,comm= -p \"$l\" && printf '%s\\n' --- && "
        'LC_ALL=C ps -ww -o pid=,lstart=,command= -p "$l"; else exit "$s"; fi'
    )


SELECTED = re.compile(r"KOINE-SELECTED ([1-9][0-9]*(?:,[1-9][0-9]*)*)")
START = (
    r"([A-Z][a-z]{2} [A-Z][a-z]{2} [ 1-3][0-9] "
    r"[0-2][0-9]:[0-5][0-9]:[0-6][0-9] [0-9]{4})"
)
IDENTITY = re.compile(r" *([1-9][0-9]*) +" + START + r" +(/.*)")
ARGUMENTS = re.compile(r" *([1-9][0-9]*) +" + START + r" +(\S.*)")


def process_parse(stdout: str, _: list[str]) -> dict[str, object]:
    if stdout == "NONE":
        return {"selected": [], "processes": []}
    rows = lines(stdout)
    selection = SELECTED.fullmatch(rows[0])
    if selection is None:
        raise ReadError("expected the selected PID set")
    selected = [int(pid) for pid in selection.group(1).split(",")]
    if len(set(selected)) != len(selected):
        raise ReadError("the selection repeats a PID")
    rows = rows[1:]
    if rows.count("---") != 1:
        raise ReadError("expected one identity block and one argument block")
    split = rows.index("---")
    identities, commands = rows[:split], rows[split + 1 :]
    if not identities or len(identities) != len(commands):
        raise ReadError("identity and argument blocks differ in length")
    processes: list[dict[str, object]] = []
    for identity, command in zip(identities, commands, strict=True):
        first, second = IDENTITY.fullmatch(identity), ARGUMENTS.fullmatch(command)
        if first is None or second is None or first.group(1) != second.group(1):
            raise ReadError(f"unparsed process rows: {identity!r} / {command!r}")
        if first.group(2) != second.group(2):
            raise ReadError(f"process rows of two starts: {identity!r} / {command!r}")
        processes.append(
            {
                "pid": int(first.group(1)),
                "started": first.group(2),
                "argv0": first.group(3),
                "arguments": second.group(3),
            }
        )
    if len({entry["pid"] for entry in processes}) != len(processes):
        raise ReadError("duplicate process rows")
    # A selected process that exited before either ps read leaves no row.
    if {entry["pid"] for entry in processes} != set(selected):
        raise ReadError("the process rows differ from the selected PID set")
    return {"selected": selected, "processes": processes}


# --- boot -----------------------------------------------------------------


def boot_command(_: list[str]) -> str:
    return "sysctl -n kern.boottime"


BOOT = re.compile(r"\{ sec = ([0-9]+), usec = ([0-9]+) \} (\S.*)")


def boot_parse(stdout: str, _: list[str]) -> dict[str, object]:
    match = BOOT.fullmatch(stdout)
    if match is None or int(match.group(2)) >= 1_000_000:
        raise ReadError("expected the kern.boottime structure")
    return {
        "sec": int(match.group(1)),
        "usec": int(match.group(2)),
        "text": match.group(3),
    }


# --- port refusal ---------------------------------------------------------


def port_command(arguments: list[str]) -> str:
    # The legacy command. Its exit status is the payload, so a refusal is data.
    return f"curl -s -m 3 -o /dev/null http://127.0.0.1:{arguments[0]}/graphql; echo $?"


def port_parse(stdout: str, _: list[str]) -> dict[str, object]:
    if re.fullmatch(r"0|[1-9][0-9]{0,2}", stdout) is None or int(stdout) > 255:
        raise ReadError("expected one curl exit status")
    return {"curl_exit": int(stdout)}


# --- diagnostic defaults --------------------------------------------------


def defaults_command(_: list[str]) -> str:
    # `defaults export` prints an empty dictionary for an absent domain, so an
    # absent key is a parsed fact, not a failed `defaults read`.
    sources = " ".join(
        f'"{MANAGED}/{name}" "{MANAGED}/$u/{name}"'
        for name in (f"{DOMAIN}.plist", ".GlobalPreferences.plist")
    )
    any_user = " ".join(f'"{path}"' for path in ANY_USER)
    return (
        "set -e; u=$(id -un); "
        f"for d in {DOMAIN} -g; do for h in any current; do "
        'printf \'KOINE-DOMAIN %s %s\\n\' "$d" "$h"; '
        'if [ "$h" = current ]; then defaults -currentHost export "$d" -; '
        'else defaults export "$d" -; fi; done; done; '
        f"for f in {sources}; do "
        'if [ -e "$f" ]; then printf \'KOINE-MANAGED %s\\n\' "$f"; '
        'plutil -convert xml1 -o - "$f"; '
        "else printf 'KOINE-ABSENT %s\\n' \"$f\"; fi; done; "
        f"for p in {any_user}; do "
        'printf \'KOINE-ANY-USER %s\\n\' "$p"; defaults export "$p" -; done; '
        "printf 'KOINE-DEFAULTS-COMPLETE'"
    )


FORBIDDEN_XML = re.compile("[\x00-\x08\x0b\x0c\x0e-\x1f\ufffe\uffff]")


def plist_value(value: object) -> object:
    if isinstance(value, bool | str) or integer(value):
        return value
    return {"type": type(value).__name__}


def defaults_parse(stdout: str, _: list[str]) -> dict[str, object]:
    rows = lines(stdout)
    if rows[-1:] != ["KOINE-DEFAULTS-COMPLETE"]:
        raise ReadError("missing defaults completion marker")
    rows = rows[:-1]
    user: str | None = None
    expected: list[tuple[str, str]] = [
        ("KOINE-DOMAIN", f"{domain} {host}")
        for domain in (DOMAIN, "-g")
        for host in ("any", "current")
    ]
    sources: list[dict[str, object]] = []
    index = 0
    for position in range(12):
        if index >= len(rows):
            raise ReadError("defaults sections end early")
        header = rows[index]
        index += 1
        kind, _space, subject = header.partition(" ")
        if position < 4:
            if (kind, subject) != expected[position]:
                raise ReadError(f"unexpected defaults section: {header!r}")
        elif position >= 8:
            if (kind, subject) != ("KOINE-ANY-USER", ANY_USER[position - 8]):
                raise ReadError(f"unexpected any-user section: {header!r}")
        else:
            name = (f"{DOMAIN}.plist", ".GlobalPreferences.plist")[(position - 4) // 2]
            match = re.fullmatch(
                re.escape(MANAGED) + r"/(?:([A-Za-z0-9_.-]+)/)?" + re.escape(name),
                subject,
            )
            wants_user = position % 2 == 1
            if (
                kind not in {"KOINE-MANAGED", "KOINE-ABSENT"}
                or match is None
                or (match.group(1) is not None) != wants_user
            ):
                raise ReadError(f"unexpected managed section: {header!r}")
            if wants_user:
                if user not in (None, match.group(1)):
                    raise ReadError("managed paths name two users")
                user = match.group(1)
            if kind == "KOINE-ABSENT":
                sources.append({"source": subject, "present": False, "keys": {}})
                continue
        # CFPropertyList escapes "<" in strings, so "</plist>" ends a body.
        try:
            end = rows.index("</plist>", index)
        except ValueError:
            raise ReadError("unterminated property list") from None
        # CFPropertyList writes C0 control characters in strings unescaped,
        # and XML 1.0 forbids them, so each becomes U+FFFD. No diagnostic key
        # name or property list tag holds one, so a key's presence survives.
        text = FORBIDDEN_XML.sub("\ufffd", "\n".join(rows[index : end + 1]))
        body = text.encode("utf-8")
        index = end + 1
        try:
            value: object = plistlib.loads(body, fmt=plistlib.FMT_XML)
        except (
            ValueError,
            ExpatError,
        ) as error:  # InvalidFileException is a ValueError.
            raise ReadError(
                f"invalid property list after {header!r}: {error}"
            ) from None
        if not isinstance(value, dict):
            raise ReadError(f"property list after {header!r} is not a dictionary")
        domain = cast(dict[str, object], value)
        keys = {
            key: plist_value(domain[key]) for key in DIAGNOSTIC_KEYS if key in domain
        }
        sources.append({"source": subject, "present": True, "keys": keys})
    if index != len(rows):
        raise ReadError("unexpected text after the defaults sections")
    found = [
        (source["source"], key, value)
        for source in sources
        for key, value in cast(dict[str, object], source["keys"]).items()
    ]
    # The protocol needs the trace and buffer keys absent and the probe absent
    # or false. A string or number is not admitted as false here.
    disabled = all(
        key == "KoineSettingsMenuProbe" and value is False for _, key, value in found
    )
    return {"user": user, "sources": sources, "diagnostics_disabled": disabled}


# --- installed inventory --------------------------------------------------


def inventory_command(_: list[str]) -> str:
    # The legacy command of record_installed_bundle, unchanged.
    return (
        f"set -euo pipefail; cd '{INSTALLED}'; "
        "find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort; "
        "find . -type l -exec stat -f '%N -> %Y' {} + | LC_ALL=C sort; "
        "echo KOINE_INVENTORY_COMPLETE"
    )


def inventory_parse(stdout: str, _: list[str]) -> dict[str, object]:
    rows = lines(stdout)
    if rows[-1:] != ["KOINE_INVENTORY_COMPLETE"]:
        raise ReadError("missing inventory completion marker")
    files: list[dict[str, str]] = []
    links: list[dict[str, str]] = []
    for row in rows[:-1]:
        file = re.fullmatch(r"([0-9a-f]{64})  (\./\S.*)", row)
        link = re.fullmatch(r"(\./\S.*?) -> (\S.*)", row)
        if file is not None and not links:
            files.append({"path": file.group(2), "sha256": file.group(1)})
        elif link is not None and file is None:
            links.append({"path": link.group(1), "target": link.group(2)})
        else:
            raise ReadError(f"unparsed inventory row: {row!r}")
    paths = [entry["path"] for entry in files + links]
    if not files or len(set(paths)) != len(paths):
        raise ReadError("inventory has no file or a repeated path")
    return {"files": files, "symlinks": links}


# --- setup records --------------------------------------------------------


def system_command(_: list[str]) -> str:
    return "sw_vers; uname -m"


def system_parse(stdout: str, _: list[str]) -> dict[str, object]:
    rows = lines(stdout)
    fields: dict[str, str] = {}
    for row in rows[:-1]:
        match = re.fullmatch(
            r"(ProductName|ProductVersion|ProductVersionExtra|BuildVersion):\t+(\S.*)",
            row,
        )
        if match is None or match.group(1) in fields:
            raise ReadError(f"unparsed sw_vers row: {row!r}")
        fields[match.group(1)] = match.group(2)
    order = [
        name
        for name in (
            "ProductName",
            "ProductVersion",
            "ProductVersionExtra",
            "BuildVersion",
        )
        if name in fields
    ]
    if (
        list(fields) != order
        or not {"ProductName", "ProductVersion", "BuildVersion"} <= set(fields)
        or fields["ProductName"] != "macOS"
        or rows[-1] not in {"arm64", "x86_64"}
    ):
        raise ReadError("expected sw_vers fields and one architecture")
    return {
        "product_version": fields["ProductVersion"],
        "product_version_extra": fields.get("ProductVersionExtra"),
        "build_version": fields["BuildVersion"],
        "arch": rows[-1],
    }


def gatekeeper_command(_: list[str]) -> str:
    return "spctl --status"


def gatekeeper_parse(stdout: str, _: list[str]) -> dict[str, object]:
    # spctl(8) documents exit 0 for success. A disabled subsystem with another
    # exit status reaches the backend as a guest failure and stays unavailable.
    if stdout not in {"assessments enabled", "assessments disabled"}:
        raise ReadError("expected the spctl status line")
    return {"assessments": stdout.removeprefix("assessments ")}


def quarantine_command(_: list[str]) -> str:
    return (
        f"n=$(xattr '{INSTALLED}') || exit; "
        "if printf '%s\\n' \"$n\" | grep -qx com.apple.quarantine; then "
        f"printf 'PRESENT\\n'; xattr -p com.apple.quarantine '{INSTALLED}'; "
        "else printf 'ABSENT'; fi"
    )


def quarantine_parse(stdout: str, _: list[str]) -> dict[str, object]:
    if stdout == "ABSENT":
        return {"present": False}
    match = re.fullmatch(r"PRESENT\n(\S[^\n]*)", stdout)
    if match is None:
        raise ReadError("expected ABSENT or PRESENT and one attribute value")
    return {"present": True, "value": match.group(1)}


def status_command(tool: str, marker: str) -> str:
    # The substitution drops the tool's trailing newlines, so exactly one
    # newline separates its text from the status marker.
    return (
        f"o=$({tool} '{INSTALLED}' 2>&1); s=$?; printf '%s\\n{marker} %s' \"$o\" \"$s\""
    )


def status_parse(stdout: str, marker: str, clean: set[int]) -> tuple[int, list[str]]:
    text, separator, status = stdout.rpartition(f"\n{marker} ")
    if (
        not separator
        or re.fullmatch(r"[0-9]+", status) is None
        or int(status) not in clean
    ):
        raise ReadError(f"expected {marker} with a documented clean status")
    return int(status), text.split("\n") if text else []


def signature_command(_: list[str]) -> str:
    return status_command(
        "codesign --verify --strict --deep --verbose=2", "KOINE-CODESIGN-STATUS"
    )


def signature_parse(stdout: str, _: list[str]) -> dict[str, object]:
    # codesign(1): 0 verified, 1 failed verification. 2 is an argument error,
    # and 3 needs -R, so both stay unavailable.
    status, text = status_parse(stdout, "KOINE-CODESIGN-STATUS", {0, 1})
    valid = [
        f"{INSTALLED}: valid on disk",
        f"{INSTALLED}: satisfies its Designated Requirement",
    ]
    if status == 0 and (
        text[-2:] != valid
        or not all(row.startswith(("--prepared:", "--validated:")) for row in text[:-2])
    ):
        raise ReadError("a clean verification lacks its two result lines")
    if status == 1 and not text:
        raise ReadError("a failed verification has no diagnostic")
    return {"valid": status == 0, "status": status, "text": text}


def display_command(_: list[str]) -> str:
    return f"codesign --display --verbose=2 '{INSTALLED}' 2>&1"


def display_parse(stdout: str, _: list[str]) -> dict[str, object]:
    rows = lines(stdout)
    single = ("Executable=", "Identifier=", "TeamIdentifier=", "CodeDirectory v=")
    if rows[:1] != [f"Executable={INSTALLED}/Contents/MacOS/Koine"] or not all(
        sum(row.startswith(prefix) for row in rows) == 1 for prefix in single
    ):
        raise ReadError("expected one executable, identifier, team and code directory")
    authorities = [
        row.removeprefix("Authority=") for row in rows if row.startswith("Authority=")
    ]
    if not authorities:
        raise ReadError("expected at least one signing authority")
    # The legacy display kept these rows only.
    shown = [
        row
        for row in rows
        if re.match(
            r"(Identifier|TeamIdentifier|Authority=Developer|CodeDirectory)", row
        )
    ]
    return {"authorities": authorities, "shown": shown, "text": rows}


def assessment_command(_: list[str]) -> str:
    return status_command("spctl -a -vv", "KOINE-SPCTL-STATUS")


def assessment_parse(stdout: str, _: list[str]) -> dict[str, object]:
    # spctl(8): 0 accepted, 3 denied. 1, 2 and 4 stay unavailable.
    status, text = status_parse(stdout, "KOINE-SPCTL-STATUS", {0, 3})
    verdict = f"{INSTALLED}: {'accepted' if status == 0 else 'rejected'}"
    if text[:1] != [verdict]:
        raise ReadError("the assessment verdict differs from its status")
    return {"accepted": status == 0, "status": status, "text": text}


# --- System Events --------------------------------------------------------

KOINE_ITEM = 'menu bar item 1 of menu bar 2 of process "Koine"'
# The fixed AppleScript of each legacy sysevents caller in vm-verify-lib.sh and
# vm-verify-menu-bar.sh. A row title is the only argument.
SYSEVENTS = {
    "sysevents-processes": "get name of every process",
    "menu-item-count": 'get count of menu bar items of menu bar 2 of process "Koine"',
    "menu-item-label": f"get description of {KOINE_ITEM}",
    "menu-item-frame": f"get {{position, size}} of {KOINE_ITEM}",
    "menu-row-frame": 'get {position, size} of menu item "%s" of menu 1 of '
    + KOINE_ITEM,
    "menu-titles": f"get title of every menu item of menu 1 of {KOINE_ITEM}",
    "dock-items": 'get name of every UI element of list 1 of process "Dock"',
    "background-only": 'get background only of process "Koine"',
    "front-application": "get name of first process whose frontmost is true",
}
# The grammar admits no quote, backslash or apostrophe, so a title cannot leave
# the AppleScript string or the shell quotes. Koine's titles end in U+2026.
ROW_TITLE = re.compile("[A-Za-z0-9](?:[A-Za-z0-9 …]*[A-Za-z0-9…])?")
# AppleScript Language Guide, "Error Numbers and Error Messages":
# -1728 "The referenced object doesn't exist" and -1719 "The specified index is
# invalid or out of range". MacErrors.h names them errAENoSuchObject and
# errAEIllegalIndex. Each other number, such as -1743 (AppleEvents.h,
# errAEEventNotPermitted), -1712 (timed out) or -600 (not running), is
# unavailable.
# https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html
ABSENT_ERRORS = {-1728, -1719}
# The number alone does not establish a missing element. System Events can
# refuse a read without Accessibility access as -1719 with its own message:
# R. Matsuda, "Scripting the Unscriptable", MacAdmins 2023, slide 29.
# https://bpb-us-e1.wpmucdn.com/sites.psu.edu/dist/4/24696/files/2023/07/psumac2023-DYQWYU-Scripting-the-unscriptable-GUI-Scripts-in-macOS.pdf#page=51
#
# When the application gives only the number, AppleScript writes the message
# itself: "Can’t get REFERENCE." for -1728 and "Can’t get REFERENCE. Invalid
# index." for -1719. The host formatter does so in any locale. Only that form,
# attributed to System Events, is an absence. Each other message is unavailable.
ABSENCE_MESSAGES = {
    -1728: re.compile(
        r"System Events got an error: Can’t get \S[^\n]*(?<! Invalid index)\."
    ),
    -1719: re.compile(
        r"System Events got an error: Can’t get \S[^\n]*\. Invalid index\."
    ),
}
OSASCRIPT_ERROR = re.compile(r"[0-9]+:[0-9]+: execution error: ([^\n]*) \((-[0-9]+)\)")
INTEGER = re.compile(r"-?(?:0|[1-9][0-9]*)")


def sysevents_command(script: str) -> str:
    # osascript(1): "-s s" prints values in recompilable source form. The
    # default human-readable form prints {"a, b"} and {"a", "b"} alike, and it
    # omits the quotes of a string. "-s o" prints a script error to stdout,
    # apart from other diagnostics on stderr. The substitution drops the one
    # newline after the value, and the status marker comes last.
    return (
        f"o=$(osascript -s so -e 'tell application \"System Events\" to {script}'); "
        's=$?; printf \'%s\\nKOINE-OSASCRIPT-STATUS %s\' "$o" "$s"'
    )


def applescript_value(text: str) -> object:
    """Parse one value in osascript's source form, or raise ReadError.

    Strings, integers, booleans, `missing value` and lists only. A string
    escapes only the quote and the backslash. A real, a record or another
    class is not a value of these reads.
    """

    def value(index: int, depth: int) -> tuple[object, int]:
        if depth > 8:
            raise ReadError("source-form value nests too deeply")
        if text.startswith('"', index):
            index += 1
            chars: list[str] = []
            while index < len(text):
                char = text[index]
                if char == '"':
                    return "".join(chars), index + 1
                if char == "\\":
                    escaped = text[index + 1 : index + 2]
                    if escaped not in {'"', "\\"}:
                        raise ReadError("unknown escape in a source-form string")
                    chars.append(escaped)
                    index += 2
                    continue
                chars.append(char)
                index += 1
            raise ReadError("unterminated source-form string")
        if text.startswith("{", index):
            items: list[object] = []
            index += 1
            if text.startswith("}", index):
                return items, index + 1
            while True:
                item, index = value(index, depth + 1)
                items.append(item)
                if text.startswith("}", index):
                    return items, index + 1
                if not text.startswith(", ", index):
                    raise ReadError("expected the source-form list separator")
                index += 2
        for word, parsed in (("missing value", None), ("true", True), ("false", False)):
            if text.startswith(word, index):
                return parsed, index + len(word)
        number = INTEGER.match(text, index)
        if number is None:
            raise ReadError(f"unparsed source-form value at {index}")
        return int(number.group(0)), number.end()

    parsed, end = value(0, 0)
    if end != len(text):
        raise ReadError("unexpected text after the source-form value")
    return parsed


def human(value: object) -> str:
    """osascript's default human-readable form of a value of these reads."""
    if isinstance(value, list):
        return ", ".join(human(item) for item in cast(list[object], value))
    if value is None:
        return "missing value"
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def text_list(value: object) -> bool:
    return isinstance(value, list) and all(
        isinstance(item, str) or item is None for item in cast(list[object], value)
    )


def frame_value(value: object) -> bool:
    # {position, size}: each part is a list of two integers or missing value.
    return (
        isinstance(value, list)
        and len(cast(list[object], value)) == 2
        and all(
            part is None
            or (
                isinstance(part, list)
                and len(cast(list[object], part)) == 2
                and all(integer(item) for item in cast(list[object], part))
            )
            for part in cast(list[object], value)
        )
    )


SYSEVENTS_TYPES: dict[str, Callable[[object], bool]] = {
    "sysevents-processes": text_list,
    "menu-item-count": lambda value: integer(value) and cast(int, value) >= 0,
    "menu-item-label": lambda value: value is None or isinstance(value, str),
    "menu-item-frame": frame_value,
    "menu-row-frame": frame_value,
    "menu-titles": text_list,
    "dock-items": text_list,
    "background-only": lambda value: isinstance(value, bool),
    "front-application": lambda value: isinstance(value, str),
}


def admits_absence(name: str, arguments: list[str]) -> bool:
    # Only the three existing polls admit a clean absence: the label poll, the
    # item frame poll of open_menu and the row frame poll of choose_menu_item.
    return name in {"menu-item-frame", "menu-row-frame"} or arguments == ["poll"]


def sysevents_read(name: str) -> Read:
    def command(arguments: list[str]) -> str:
        script = SYSEVENTS[name]
        return sysevents_command(
            script % arguments[0] if name == "menu-row-frame" else script
        )

    def parse(stdout: str, arguments: list[str]) -> dict[str, object]:
        lines(stdout)
        text, separator, status = stdout.rpartition("\nKOINE-OSASCRIPT-STATUS ")
        if not separator or status not in {"0", "1"}:
            # osascript exits 0 with a result and 1 with a script error.
            raise ReadError("expected osascript status 0 or 1 after the output")
        if status == "1":
            error = OSASCRIPT_ERROR.fullmatch(text)
            if error is None:
                raise ReadError("osascript status 1 without one execution error")
            number = int(error.group(2))
            if number not in ABSENT_ERRORS:
                raise ReadError(f"AppleScript error {number} is unavailable")
            if ABSENCE_MESSAGES[number].fullmatch(error.group(1)) is None:
                raise ReadError(
                    f"AppleScript error {number} does not report a missing element"
                )
            if not admits_absence(name, arguments):
                raise ReadError(
                    f"AppleScript error {number} is an absence that only a poll admits"
                )
            return {"absent": True, "error": number, "message": error.group(1)}
        value = applescript_value(text)
        if not SYSEVENTS_TYPES[name](value):
            raise ReadError(f"{name} returned a value of another type")
        if name in {"menu-item-frame", "menu-row-frame"}:
            # click_centre parses the human-readable form of {position, size}.
            return {"absent": False, "value": value, "text": human(value)}
        return {"absent": False, "value": value}

    def valid(arguments: list[str]) -> bool:
        if name == "menu-item-label":
            return arguments in (["value"], ["poll"])
        if name == "menu-row-frame":
            return len(arguments) == 1 and ROW_TITLE.fullmatch(arguments[0]) is not None
        return arguments == []

    # An Apple event can launch System Events and can raise its Automation
    # consent prompt, so no System Events read is read-only.
    return Read(command, parse, valid, False, "an Apple event can start System Events")


# --- enrolment ------------------------------------------------------------

ENROL_SECRET = re.compile(r"\$HOME/koine-secret-[a-z]+")
ENROL_LABEL = re.compile(r"[a-z][a-z0-9-]{0,62}")


def enrol_command(arguments: list[str]) -> str:
    # The legacy enrol command of vm-verify-menu-bar.sh. The guest expands $HOME.
    return (
        "python3 $HOME/vm-verify-enrollment-client.py "
        f'"{arguments[0]}" enrol "{arguments[1]}" desktop:read'
    )


def enrol_parse(stdout: str, _: list[str]) -> dict[str, object]:
    # The client prints exactly one JSON object on one line. A second line,
    # such as a traceback before the object, is not the client's answer.
    if "\n" in stdout or not stdout.startswith("{"):
        raise ReadError("expected exactly one JSON line from the enrolment client")
    lines(stdout)
    try:
        value: object = json.loads(
            stdout, object_pairs_hook=unique_object, parse_constant=reject_constant
        )
    except json.JSONDecodeError as error:
        raise ReadError(f"enrolment answer is not one JSON object: {error}") from None
    if not isinstance(value, dict):
        raise ReadError("enrolment answer is not one JSON object")
    answer = cast(dict[str, object], value)
    status, response = answer.get("status"), answer.get("response")
    # scripts/vm-verify-enrollment-client.py owns these fields.
    if not (
        sorted(answer) == ["case", "response", "status"]
        and answer["case"] == "enrol"
        and integer(status)
        and 100 <= cast(int, status) <= 599
        and (response is None or isinstance(response, dict))
    ):
        raise ReadError("enrolment answer differs from the client's schema")
    return {"case": "enrol", "status": status, "response": response}


def enrol_arguments(arguments: list[str]) -> bool:
    return (
        len(arguments) == 2
        and ENROL_SECRET.fullmatch(arguments[0]) is not None
        and ENROL_LABEL.fullmatch(arguments[1]) is not None
    )


# --- launch identity ------------------------------------------------------

EXECUTABLE = f"{INSTALLED}/Contents/MacOS/Koine"
# The guest Python reads the kernel's record of the descriptor's PID. ps prints
# argv[0], which the process sets, so it cannot give the executable.
# libproc.h declares proc_pidpath(pid, buffer, size) and proc_pidinfo(pid,
# flavor, arg, buffer, size). sys/proc_info.h gives PROC_PIDTBSDINFO = 3,
# PROC_PIDPATHINFO_MAXSIZE = 4 * MAXPATHLEN and the proc_bsdinfo fields below,
# which end in the start time in seconds and microseconds. Host SDK digests:
# libproc.h 246d8770…, sys/proc_info.h e427fa96…. Each call fails with ESRCH
# for a PID that no longer exists, which is the clean fact "no process". Two
# reads of the start time around the path read reject a PID reused between
# them. The script holds no apostrophe, because the shell quotes it.
IDENTITY_SCRIPT = """import ctypes, errno, json, sys
u32 = ctypes.c_uint32
class Info(ctypes.Structure):
    _fields_ = [(n, u32) for n in ("flags", "status", "xstatus", "pid", "ppid",
        "uid", "gid", "ruid", "rgid", "svuid", "svgid", "rfu")] + [
        ("comm", ctypes.c_char * 16), ("name", ctypes.c_char * 32)] + [
        (n, u32) for n in ("nfiles", "pgid", "pjobc", "tdev", "tpgid")] + [
        ("nice", ctypes.c_int32), ("sec", ctypes.c_uint64), ("usec", ctypes.c_uint64)]
lib = ctypes.CDLL("/usr/lib/libSystem.B.dylib", use_errno=True)
text = open(sys.argv[1], encoding="utf-8").read()
pid = json.loads(text).get("pid")
if type(pid) is not int or pid <= 0:
    sys.exit(3)
def info():
    value = Info()
    size = lib.proc_pidinfo(pid, 3, 0, ctypes.byref(value), ctypes.sizeof(value))
    if size == ctypes.sizeof(value):
        return value
    if size <= 0 and ctypes.get_errno() == errno.ESRCH:
        return None
    sys.exit(4)
def path():
    buffer = ctypes.create_string_buffer(4096)
    size = lib.proc_pidpath(pid, buffer, 4096)
    if size > 0:
        return buffer.raw[:size].decode("utf-8")
    if ctypes.get_errno() == errno.ESRCH:
        return None
    sys.exit(5)
first, executable, second = info(), path(), info()
process = None
if first is not None and executable is not None and second is not None:
    if (first.pid, first.sec, first.usec) != (second.pid, second.sec, second.usec):
        sys.exit(6)
    process = {"pid": first.pid, "start_sec": first.sec,
        "start_usec": first.usec, "executable": executable}
print(json.dumps({"descriptor_text": text, "process": process}, sort_keys=True))
"""


def identity_command(_: list[str]) -> str:
    pattern = PROCESS_PATTERNS["executable"]
    # The pgrep selection precedes the kernel read, as in the process read.
    return (
        f"f={DESCRIPTOR}; if [ ! -e \"$f\" ]; then printf 'ABSENT'; exit 0; fi; "
        f"p=$(pgrep -f '{pattern}'); s=$?; "
        'if [ "$s" -gt 1 ]; then exit "$s"; fi; '
        "printf 'KOINE-SELECTED %s\\n' \"$(printf '%s' \"$p\" | tr '\\n' ,)\"; "
        f"python3 -I -c '{IDENTITY_SCRIPT}' \"$f\""
    )


IDENTITY_SELECTED = re.compile(r"KOINE-SELECTED ((?:[1-9][0-9]*(?:,[1-9][0-9]*)*)?)")


def identity_parse(stdout: str, _: list[str]) -> dict[str, object]:
    if stdout == "ABSENT":
        return {"present": False, "joined": False}
    rows = lines(stdout)
    selection = IDENTITY_SELECTED.fullmatch(rows[0])
    if selection is None or len(rows) != 2:
        raise ReadError("expected the selected PID set and one identity line")
    selected = [int(pid) for pid in selection.group(1).split(",") if pid]
    if len(set(selected)) != len(selected):
        raise ReadError("the selection repeats a PID")
    try:
        value: object = json.loads(
            rows[1], object_pairs_hook=unique_object, parse_constant=reject_constant
        )
    except json.JSONDecodeError as error:
        raise ReadError(f"identity line is not one JSON object: {error}") from None
    if not isinstance(value, dict):
        raise ReadError("identity line is not one JSON object")
    answer = cast(dict[str, object], value)
    text, process = answer.get("descriptor_text"), answer.get("process")
    if sorted(answer) != ["descriptor_text", "process"] or not isinstance(text, str):
        raise ReadError("identity line differs from the script's schema")
    descriptor = descriptor_fields(text)
    if process is not None:
        if not isinstance(process, dict):
            raise ReadError("identity process is not an object")
        entry = cast(dict[str, object], process)
        start_usec = entry.get("start_usec")
        if not (
            sorted(entry) == ["executable", "pid", "start_sec", "start_usec"]
            and entry["pid"] == descriptor["pid"]
            and integer(entry["start_sec"])
            and cast(int, entry["start_sec"]) > 0
            and integer(start_usec)
            and 0 <= cast(int, start_usec) < 1_000_000
            and isinstance(entry["executable"], str)
            and entry["executable"].startswith("/")
        ):
            raise ReadError("identity process differs from the script's schema")
    joined = (
        isinstance(process, dict)
        and cast(dict[str, object], process)["executable"] == EXECUTABLE
        and selected == [descriptor["pid"]]
    )
    return {
        "present": True,
        "selected": selected,
        "descriptor": descriptor,
        "process": process,
        "joined": joined,
    }


# --- one-shot submissions -------------------------------------------------

# Each legacy one-shot command, unchanged, and its exact clean stdout. The agent
# waits for the bash process only, so a background job leaves empty stdout.
# https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift
SUBMISSIONS: dict[str, tuple[str, str]] = {
    # install_app in vm-verify-lib.sh.
    "extract-bundle": ("ditto -x -k /tmp/Koine.zip /Applications", ""),
    # The first launch, the silent launch and the reopen of vm-verify-menu-bar.sh.
    "open-koine": (f"open {INSTALLED}", ""),
    "open-textedit": ("open -a TextEdit", ""),
    "quit-textedit": (
        "osascript -e 'tell application \"TextEdit\" to quit saving no'",
        "",
    ),
    # grant_system_events_automation in vm-verify-lib.sh.
    "request-automation": (
        (
            'nohup osascript -e \'tell application "System Events" to get name of '
            "every process' >/dev/null 2>&1 &"
        ),
        "",
    ),
    # grant_accessibility in vm-verify-desktop-lib.sh.
    "open-accessibility-pane": (
        (
            'open "x-apple.systempreferences:com.apple.preference.security'
            '?Privacy_Accessibility"'
        ),
        "",
    ),
    # shutdown.c on the `now` path skips the fork, prints these two lines, calls
    # reboot3 and exits 0 through finish(0) if that call returns. The lock
    # failure path exits 0 after the first line only. The agent strips the
    # trailing CR LF, and BEL is not whitespace. The password is the legacy one.
    # https://github.com/apple-oss-distributions/system_cmds/blob/main/shutdown/shutdown.c
    "restart": (
        "echo admin | sudo -S shutdown -r now",
        "Shutdown NOW!\n\r\nSystem shutdown time has arrived\x07\x07",
    ),
}


def submission_read(name: str) -> Read:
    command, clean = SUBMISSIONS[name]

    def parse(stdout: str, _: list[str]) -> dict[str, object]:
        if stdout != clean:
            raise ReadError(f"submission {name} printed other stdout")
        return {"submitted": True, "stdout": stdout}

    return Read(
        lambda _: command,
        parse,
        no_arguments,
        False,
        f"submission {name} sends input",
        one_shot=True,
    )


# --- the table ------------------------------------------------------------


@dataclass(frozen=True)
class Read:
    command: Callable[[list[str]], str]
    parse: Callable[[str, list[str]], dict[str, object]]
    arguments: Callable[[list[str]], bool]
    # Admitted after a latch only when the read changes no guest state.
    evidence: bool
    why: str
    # A checked submission sends input, so it admits only the one-shot class.
    one_shot: bool = False


def no_arguments(arguments: list[str]) -> bool:
    return arguments == []


READS: dict[str, Read] = {
    "endpoint": Read(
        endpoint_command, endpoint_parse, no_arguments, True, "test and cat"
    ),
    "process": Read(
        process_command,
        process_parse,
        lambda arguments: len(arguments) == 1 and arguments[0] in PROCESS_PATTERNS,
        True,
        "pgrep and ps",
    ),
    "boot": Read(boot_command, boot_parse, no_arguments, True, "sysctl read"),
    "port-refusal": Read(
        port_command,
        port_parse,
        lambda arguments: (
            len(arguments) == 1
            and re.fullmatch(r"[1-9][0-9]{0,4}", arguments[0]) is not None
            and int(arguments[0]) <= 65535
        ),
        False,
        "curl sends a request to any live listener",
    ),
    "defaults": Read(
        defaults_command, defaults_parse, no_arguments, True, "defaults export"
    ),
    "installed-inventory": Read(
        inventory_command, inventory_parse, no_arguments, True, "find, shasum and stat"
    ),
    "system": Read(
        system_command, system_parse, no_arguments, True, "sw_vers and uname"
    ),
    "gatekeeper": Read(
        gatekeeper_command, gatekeeper_parse, no_arguments, True, "status query"
    ),
    "quarantine": Read(
        quarantine_command, quarantine_parse, no_arguments, True, "xattr list"
    ),
    "signature": Read(
        signature_command, signature_parse, no_arguments, True, "verification"
    ),
    "signature-display": Read(
        display_command, display_parse, no_arguments, True, "display"
    ),
    # spctl(8): an assessment stores its outcome in the assessment cache unless
    # --no-cache is given. The legacy command has no --no-cache.
    "assessment": Read(
        assessment_command,
        assessment_parse,
        no_arguments,
        False,
        "spctl -a writes the assessment cache",
    ),
    **{name: sysevents_read(name) for name in SYSEVENTS},
    # The client sends a grant request, so the enrolment is a submission.
    "enrol": Read(
        enrol_command,
        enrol_parse,
        enrol_arguments,
        False,
        "the enrolment sends a grant request",
        one_shot=True,
    ),
    # Python can raise the Command Line Tools prompt where they are absent.
    "launch-identity": Read(
        identity_command,
        identity_parse,
        no_arguments,
        False,
        "python3 can raise the Command Line Tools prompt",
    ),
    **{name: submission_read(name) for name in SUBMISSIONS},
}


def command(name: str, kind: str, arguments: list[str]) -> str:
    """Return the exact guest command, or raise for an unadmitted request."""
    read = READS.get(name)
    if read is None:
        raise ValueError(f"unknown checked read: {name}")
    if read.one_shot:
        if kind != "one-shot":
            raise ValueError(f"checked submission {name} needs the one-shot class")
    elif kind not in {"read-poll", "evidence"}:
        raise ValueError("a checked read needs the read-poll or evidence class")
    if kind == "evidence" and not read.evidence:
        raise ValueError(f"evidence class refuses read {name}: {read.why}")
    if not read.arguments(arguments):
        raise ValueError(f"invalid arguments for checked read {name}")
    return read.command(arguments)


def parse(name: str, stdout: str, arguments: list[str]) -> dict[str, object]:
    return {
        "read": name,
        "arguments": arguments,
        **READS[name].parse(stdout, arguments),
    }
