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
    return {"present": True, "descriptor": descriptor}


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


# --- the table ------------------------------------------------------------


@dataclass(frozen=True)
class Read:
    command: Callable[[list[str]], str]
    parse: Callable[[str, list[str]], dict[str, object]]
    arguments: Callable[[list[str]], bool]
    # Admitted after a latch only when the read changes no guest state.
    evidence: bool
    why: str


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
}


def command(name: str, kind: str, arguments: list[str]) -> str:
    """Return the exact guest command, or raise for an unadmitted request."""
    read = READS.get(name)
    if read is None:
        raise ValueError(f"unknown checked read: {name}")
    if kind not in {"read-poll", "evidence"}:
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
