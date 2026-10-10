"""Executable source/root operation grammar; all platform names are trace labels.

Inputs are explicit observations, never invented native captures. Unknown owned
capacities propagate to an unknown gross sum. Ledger enforces attempt/cleanup
admission only; this symbolic model is not a numeric owned-byte admission proof.
"""
# pyright: strict

from __future__ import annotations

from dataclasses import dataclass

from application_metadata_operation_ledger import ContractViolation, Ledger, Limit, Resource


@dataclass(frozen=True)
class Receipt:
    label: str
    kind: str
    amount: int | None


class NativeRefusal(ValueError):
    """A declared construction returned no owner; not a checked negative."""


class Trace:
    def __init__(self, *, attempts: int = 4194304, cut: int | None = None,
                 nil_acquisition: str | None = None) -> None:
        self.ledger = Ledger(attempts=attempts)
        self.receipts: list[Receipt] = []
        self.cut = cut
        self.serial = 0
        self.invocations = 0
        self.snapshots: set[str] = set()
        self.identifiers: set[bytes] = set()
        self.nil_acquisition = nil_acquisition

    @property
    def operations(self) -> list[str]:
        return self.ledger.operations

    @property
    def unresolved(self) -> list[str]:
        return [item.label for item in self.receipts
                if item.kind != "opaque" and item.amount is None]

    @property
    def known_writes(self) -> int:
        return sum(item.amount for item in self.receipts
                   if item.kind == "write" and item.amount is not None)

    @property
    def gross(self) -> int | None:
        owned = [item for item in self.receipts if item.kind != "opaque"]
        if any(item.amount is None for item in owned):
            return None
        return sum(item.amount for item in owned if item.amount is not None)

    def invoke(self, label: str, possible: tuple[Resource, ...] = (),
               acquired: tuple[str, ...] | None = None) -> None:
        if self.cut is not None and self.invocations >= self.cut:
            self.ledger.freeze("CANCELLED")
            raise Limit("CANCELLED")
        self.ledger.begin(label, possible)
        self.invocations += 1
        self.ledger.finish(tuple(item.name for item in possible) if acquired is None else acquired)

    def opaque(self, label: str, name: str, *, disposer: str = "ARC.release",
               present: bool = True) -> None:
        nil = self.nil_acquisition == label
        present = present and not nil
        self.invoke(label, (Resource(name, disposer),), (name,) if present else ())
        if nil:
            raise NativeRefusal(label)
        if present:
            self.receipts.append(Receipt(name + ".native-footprint", "opaque", None))
            if disposer.startswith("ARC."):
                self.invoke("ARC.retain-projection." + name)

    def write(self, label: str, amount: int | None) -> None:
        if amount is not None and amount < 0:
            raise ContractViolation("negative payload")
        self.invoke("owned.write." + label)
        self.receipts.append(Receipt(label, "write", amount))

    def allocate(self, label: str, capacity: int | None) -> str:
        if capacity is not None and capacity < 0:
            raise ContractViolation("negative capacity")
        self.serial += 1
        name = f"owned-{self.serial}"
        self.invoke("owned.allocate." + label,
                    (Resource(name, "owned.free", representation="OWNED"),))
        self.receipts.append(Receipt(label + ".capacity", "allocate", capacity))
        return name

    def bytes(self, label: str, data: bytes, *, capacity: int | None = None) -> str:
        if capacity is not None and capacity < len(data):
            raise ContractViolation("payload exceeds allocation")
        name = self.allocate(label, capacity)
        self.write(label, len(data))
        return name

    def vector(self, label: str, count: int, *, populate: bool = True) -> str:
        if count < 0:
            raise ContractViolation("negative vector count")
        # Native UInt/CFIndex pointers are eight bytes on the supported 64-bit
        # subject. Container header/capacity/growth/alignment is not derived here.
        owner = self.allocate(label, None)
        if populate:
            self.write(label + ".population", 8 * count)
        return owner

    def release(self, owner: str) -> None:
        self.ledger.dispose(owner)

    def record(self, label: str) -> str:
        owner = self.allocate(label, None)
        self.write(label + ".field-values", None)
        return owner

    def cleanup(self) -> None:
        self.ledger.retire_all()
        self.ledger.return_slot()

    def once(self, name: str) -> None:
        if name in self.snapshots:
            raise ContractViolation("repeated job snapshot")
        self.snapshots.add(name)


def setup(trace: Trace) -> None:
    trace.once("setup")
    for name in ("CFString", "CFArray", "CFURL", "CFError", "CFBoolean", "CFDictionary"):
        trace.invoke(name + "GetTypeID")


@dataclass(frozen=True)
class Scalar:
    data: bytes = b""
    state: str = "OK"


@dataclass(frozen=True)
class IndexedItem:
    path: Scalar
    tree: tuple[Scalar, ...]
    identifier: Scalar = Scalar(state="MISSING")
    name: Scalar = Scalar(state="MISSING")
    state: str = "OK"
    tree_state: str = "OK"


@dataclass(frozen=True)
class RunningItem:
    url: Scalar
    identifier: Scalar = Scalar(state="MISSING")
    state: str = "OK"


@dataclass(frozen=True)
class Batch:
    branch: str
    urls: tuple[Scalar, ...] = ()
    error_state: str = "OK"


def scalar(trace: Trace, value: Scalar, label: str) -> bool:
    if value.state not in {"OK", "MISSING", "TYPE", "ENCODING", "INCOMPLETE"}:
        raise ContractViolation("unknown scalar branch")
    if value.state == "MISSING":
        return False
    trace.invoke("CFGetTypeID." + label)
    if value.state == "TYPE":
        return False
    trace.invoke("CFStringGetLength." + label)
    trace.invoke("CFStringGetMaximumSizeForEncoding." + label)
    buffer = trace.allocate(label + ".utf8-scratch", None)
    trace.invoke("CFStringGetBytes." + label)
    trace.write(label + ".utf8-prefix", len(value.data))
    valid = value.state == "OK"
    if valid:
        trace.bytes(label + ".projection", value.data + b"\0")
    trace.release(buffer)
    return valid


def url(trace: Trace, value: Scalar, label: str) -> bool:
    trace.invoke("raw.url.admit")  # before classification or equality/dedup
    if value.state == "MISSING":
        return False
    trace.invoke("raw.url.bridge-check")
    trace.invoke("CFGetTypeID.url")
    if value.state == "TYPE":
        return False
    trace.invoke("NSURL.isFileURL")
    if value.state in {"INCOMPLETE", "NON_FILE"}:
        return False
    trace.opaque("CFURLCopyFileSystemPath", "url-path", disposer="CFRelease.url-path",
                 present=value.state != "COPY_NIL")
    if value.state == "COPY_NIL":
        return False
    good = scalar(trace, value, label)
    trace.release("url-path")
    trace.record(label + ".observation-record")
    return good


def indexed(trace: Trace, items: tuple[IndexedItem, ...], *, branch: str = "POSITIVE",
            events: int = 1) -> None:
    trace.once("indexed")
    if events < 1:
        raise ContractViolation("no terminal event or failure observation")
    if branch not in {"INIT_NIL", "START_FALSE", "ERROR", "INCOMPLETE", "EMPTY", "POSITIVE"}:
        raise ContractViolation("unknown query branch")
    trace.opaque("autoreleasepool.push.query", "query-pool", disposer="autoreleasepool.drain")
    trace.bytes("query.fixed-predicate", b"kMDItemContentTypeTree = com.apple.application-bundle\0")
    trace.vector("query.scope-vector", 1)
    trace.opaque("NSPredicate.construct.fixed", "predicate", disposer="ARC.release.predicate")
    trace.opaque("NSMetadataQuery.alloc.init", "query", disposer="ARC.release.query",
                 present=branch != "INIT_NIL")
    if branch != "INIT_NIL":
        trace.invoke("NSMetadataQuery.setPredicate")
        trace.invoke("NSMetadataQuery.setSearchScopes.IndexedLocalComputer")
        trace.invoke("NotificationCenter.default")
        trace.opaque("NotificationCenter.addObserver.didFinishGathering", "observer",
                     disposer="NotificationCenter.removeObserver")
        # Reserving stop before start is essential even on a cancellation return.
        trace.invoke("NSMetadataQuery.start", (Resource("active-query", "NSMetadataQuery.stop"),),
                     () if branch == "START_FALSE" else ("active-query",))
        if branch != "START_FALSE":
            for _ in range(events):
                trace.invoke("owner-runloop.wait-event")
                trace.invoke("notification.object.type-and-query-identity")
            if branch not in {"ERROR", "INCOMPLETE"}:
                trace.invoke("NSMetadataQuery.disableUpdates")
                trace.invoke("NSMetadataQuery.resultCount")
                trace.invoke("raw.indexed.count-admit")
                for item in items:
                    trace.invoke("raw.url.admit")
                    trace.opaque("autoreleasepool.push.item", "item-pool",
                                 disposer="autoreleasepool.drain")
                    trace.invoke("NSMetadataQuery.resultAtIndex")
                    trace.invoke("raw.item.bridge-and-class-check")
                    if item.state == "OK":
                        for field in ("kMDItemPath", "kMDItemContentTypeTree",
                                      "kMDItemCFBundleIdentifier", "kMDItemDisplayName"):
                            trace.invoke("NSMetadataItem.valueForAttribute." + field)
                        if item.tree_state != "MISSING":
                            trace.invoke("CFGetTypeID.type-tree")
                        tree_valid = item.tree_state == "OK"
                        if tree_valid:
                            trace.invoke("CFArrayGetCount.type-tree")
                            for key in item.tree:
                                trace.invoke("CFArrayGetValueAtIndex.type-tree")
                                tree_valid = scalar(trace, key, "type-tree-member") and tree_valid
                        for label, value in (("indexed-path", item.path),
                                             ("indexed-identifier", item.identifier),
                                             ("indexed-name", item.name)):
                            scalar(trace, value, label)
                        trace.invoke("indexed.exact-tree-membership-and-tuple-classification")
                        trace.record("indexed.tuple-record")
                        if not tree_valid:
                            trace.invoke("indexed.incomplete-summary")
                    else:
                        trace.invoke("indexed.refused-item-summary")
                    trace.release("item-pool")
            trace.release("active-query")
        trace.release("observer")
        trace.release("query")
    trace.release("predicate")
    trace.release("query-pool")


def running(trace: Trace, items: tuple[RunningItem, ...], *, branch: str = "POSITIVE") -> None:
    trace.once("running")
    trace.opaque("autoreleasepool.push.running", "running-pool",
                 disposer="autoreleasepool.drain")
    trace.invoke("NSWorkspace.shared")
    trace.opaque("NSWorkspace.runningApplications", "running-batch",
                 disposer="ARC.release.running-batch")
    trace.vector("running.swift-vector", len(items))  # overlay materialization is owned
    trace.invoke("raw.running.count-admit")
    if branch == "POSITIVE":
        for item in items:
            trace.invoke("raw.running.access")
            trace.invoke("raw.running.bridge-and-class-check")
            if item.state != "OK":
                trace.invoke("running.incomplete-summary")
                continue
            trace.invoke("NSRunningApplication.bundleURL")
            trace.invoke("NSRunningApplication.bundleIdentifier")
            trace.invoke("NSRunningApplication.activationPolicy")
            url(trace, item.url, "running-path")
            scalar(trace, item.identifier, "running-identifier")
            trace.record("running.policy-record")
    elif branch not in {"EMPTY", "INCOMPLETE", "ERROR"}:
        raise ContractViolation("unknown running branch")
    trace.release("running-batch")
    trace.release("running-pool")


def preferences(trace: Trace, values: tuple[Scalar, ...], *, fail_at: int | None = None) -> bool:
    trace.once("preferences")
    trace.opaque("autoreleasepool.push.preferences", "preferences-pool",
                 disposer="autoreleasepool.drain")
    trace.invoke("Locale.preferredLanguages")
    snapshot = trace.vector("preferences.swift-snapshot", len(values))
    trace.invoke("preferences.count-and-bridge")
    pointers = trace.vector("preferences.cf-pointer-vector", len(values), populate=False)
    created: list[str] = []
    complete = False
    for index, value in enumerate(values):
        trace.invoke("preferences.raw-access")
        trace.invoke("preferences.raw-bridge")
        if not scalar(trace, value, "preference"):
            break
        owner = f"preference-{index}"
        trace.opaque("CFStringCreateWithBytes.preference", owner,
                     disposer="CFRelease.preference", present=index != fail_at)
        if index == fail_at:
            break
        created.append(owner)
        trace.write("preferences.cf-pointer-slot", 8)
    else:
        trace.opaque("CFArrayCreate.preferences", "preference-array",
                     disposer="CFRelease.preference-array", present=fail_at != len(values))
        complete = "preference-array" in trace.ledger.resources
    if not complete:
        for owner in reversed(created):
            trace.release(owner)
    trace.release(pointers)
    trace.release(snapshot)
    trace.release("preferences-pool")
    # Successful CF array/string owners survive until the job's last selector.
    return complete


def registration(trace: Trace, cf: Batch, appkit: Batch, preferred: Scalar | None,
                 identifier: bytes) -> str:
    if identifier in trace.identifiers:
        raise ContractViolation("recursive or repeated identifier expansion")
    trace.identifiers.add(identifier)
    trace.bytes("registration.seed", identifier + b"\0")
    trace.opaque("CFStringCreateWithBytes.seed", "seed", disposer="CFRelease.seed")
    trace.opaque("autoreleasepool.push.registration", "registration-pool",
                 disposer="autoreleasepool.drain")
    branches = {"POSITIVE", "EMPTY", "NOT_FOUND", "ERROR", "BOTH", "NIL",
                "WRONG_TYPE", "INCOMPLETE"}
    if cf.branch not in branches or appkit.branch not in branches:
        raise ContractViolation("unknown registration branch")
    if cf.error_state not in {"OK", "TYPE"}:
        raise ContractViolation("unknown registration error type")
    array = cf.branch in {"POSITIVE", "EMPTY", "BOTH", "WRONG_TYPE", "INCOMPLETE"}
    error = cf.branch in {"NOT_FOUND", "ERROR", "BOTH"}
    outputs = tuple(name for name, present in (("cf-list", array), ("cf-error", error))
                    if present)
    trace.invoke("LSCopyApplicationURLsForBundleIdentifier", (
        Resource("cf-list", "CFRelease.registration-list"),
        Resource("cf-error", "CFRelease.registration-error"),
    ), outputs)
    valid = cf.branch == "POSITIVE" and bool(cf.urls)
    if array:
        trace.receipts.append(Receipt("cf-list.native-footprint", "opaque", None))
        trace.invoke("CFGetTypeID.registration-list")
        if cf.branch != "WRONG_TYPE":
            trace.invoke("CFArrayGetCount.registration-list")
            trace.invoke("raw.registration.count-admit")
            for value in cf.urls:
                trace.invoke("CFArrayGetValueAtIndex.registration-list")
                valid = url(trace, value, "registration-cf-path") and valid
    if error:
        trace.receipts.append(Receipt("cf-error.native-footprint", "opaque", None))
        trace.invoke("CFGetTypeID.registration-error")
        if cf.error_state == "OK":
            trace.invoke("CFErrorGetDomain")
            trace.invoke("CFErrorGetCode")
        trace.release("cf-error")
    if array:
        trace.release("cf-list")
    trace.opaque("NSWorkspace.urlsForApplications", "appkit-list",
                 disposer="ARC.release.appkit-list")
    trace.vector("registration.appkit-swift-vector", len(appkit.urls))
    trace.invoke("appkit-list.count-and-bridge")
    appkit_valid = appkit.branch in {"POSITIVE", "EMPTY"}
    for value in appkit.urls:
        trace.invoke("appkit-list.raw-access")
        appkit_valid = url(trace, value, "registration-appkit-path") and appkit_valid
    trace.release("appkit-list")
    trace.opaque("NSWorkspace.urlForApplication", "preferred-url",
                 disposer="ARC.release.preferred-url", present=preferred is not None)
    if preferred is not None:
        appkit_valid = url(trace, preferred, "registration-preferred-path") and appkit_valid
        trace.release("preferred-url")
    trace.vector("registration.ordered-domain", len(appkit.urls) + int(preferred is not None))
    trace.release("registration-pool")
    trace.release("seed")
    if (cf.branch == "NOT_FOUND" and cf.error_state == "OK" and appkit_valid
            and not appkit.urls and preferred is None):
        return "CHECKED_NOT_FOUND"
    return "COMPLETE" if valid and appkit_valid else "UNKNOWN"


@dataclass(frozen=True)
class Visit:
    name: bytes
    kind: str
    text: bytes = b""
    failure: str = ""
    identity: int = 1
    containing_identity: int = 1


@dataclass(frozen=True)
class WalkResult:
    identity: int
    resolved: bytes
    visits: int
    directory: bool = True


def c_name(trace: Trace, name: bytes, label: str) -> None:
    # DarwinWalkSystem.name maps all CChars, then appends NUL into a new array.
    trace.bytes(label + ".map-cchar", name)
    trace.bytes(label + ".with-nul", name + b"\0")


def walk(trace: Trace, literal: bytes, observations: tuple[Visit, ...], *,
         transfer: bool, root_failure: bool = False,
         current_status_failure: bool = False) -> WalkResult | None:
    """Byte parser and scripted observations corresponding to LocationWalk.

    Exact payload writes are receipts. Array/map/set growth and representation
    capacities remain unknown. Existing semantics plus terminal transfer only.
    """
    trace.bytes("walk.literal", literal)
    trace.record("walk.state")
    trace.opaque("openat.root", "current", disposer="close", present=not root_failure)
    if root_failure:
        return None
    pending = literal
    stack: list[bytes] = []
    visited: set[tuple[int, bytes, bytes]] = set()
    link_texts: dict[int, bytes] = {}
    expansion_count = 0
    count = 0
    cursor = 0
    result: WalkResult | None = None
    final_component_count = 0
    try:
        while True:
            while cursor < len(pending) and pending[cursor] == 47:
                cursor += 1
            if cursor == len(pending):
                trace.invoke("fstat.current")
                if current_status_failure:
                    break
                identity = 1
                result = WalkResult(identity, b"/" + b"/".join(stack), count)
                final_component_count = len(stack)
                break
            start = cursor
            while cursor < len(pending) and pending[cursor] != 47:
                cursor += 1
            name = pending[start:cursor]
            rest = pending[cursor:]
            trace.bytes("walk.component", name)
            if count >= len(observations) or observations[count].name != name:
                raise ContractViolation("scripted visit does not match expanded pending path")
            visit = observations[count]
            count += 1
            final = not rest.strip(b"/")
            if name == b".":
                if final:
                    trace.invoke("fstat.current")
                    if visit.failure or current_status_failure:
                        break
                    result = WalkResult(visit.identity, b"/" + b"/".join(stack), count)
                    final_component_count = len(stack)
                    break
                continue
            if name == b".." and not final:
                c_name(trace, name, "walk.parent-open-c-string")
                trace.opaque("openat.parent", "next", disposer="close",
                             present=not visit.failure)
                if visit.failure:
                    if visit.failure == "ENAMETOOLONG":
                        trace.invoke("fpathconf")
                    break
                trace.release("current")
                trace.ledger.transfer("next", Resource("current", "close"))
                if stack:
                    stack.pop()
                trace.invoke("owned.stack-pop")
                continue
            c_name(trace, name, "walk.component-c-string")
            trace.invoke("fstatat.before")
            if visit.kind == "ERROR" or visit.failure == "STATUS":
                if visit.failure == "ENAMETOOLONG":
                    trace.invoke("fpathconf")
                break
            if visit.kind == "LINK":
                trace.bytes("walk.link-read-buffer-zeroing", bytes(1025))
                c_name(trace, name, "walk.link-read-c-string")
                trace.invoke("readlinkat")
                trace.write("walk.link-read-prefix", min(len(visit.text), 1025))
                if visit.failure in {"LINK", "ENAMETOOLONG"}:
                    if visit.failure == "ENAMETOOLONG":
                        trace.invoke("fpathconf")
                    break
                if len(visit.text) >= 1025:
                    trace.invoke("fpathconf")
                    break
                trace.bytes("walk.link-text-prefix-copy", visit.text)
                if visit.failure == "CHANGED" or (
                    visit.identity in link_texts and link_texts[visit.identity] != visit.text
                ):
                    break
                link_texts[visit.identity] = visit.text
                trace.vector("walk.link-text-map-entry", 1)
                trace.bytes("walk.link-text-map-value", visit.text)
                if not visit.text or visit.failure == "EMPTY":
                    break
                trace.invoke("fstat.containing")
                if visit.failure == "CONTAINING":
                    break
                suffix = b"/".join(part for part in rest.split(b"/") if part)
                if rest.startswith(b"/"):
                    suffix = b"/" + suffix
                if rest.endswith(b"/") and suffix != b"/":
                    suffix += b"/"
                trace.bytes("walk.collapsed-suffix", suffix)
                state = (visit.containing_identity, visit.text, suffix)
                trace.invoke("owned.cycle-key-lookup")
                if state in visited or expansion_count == 32:
                    break
                visited.add(state)
                trace.vector("walk.cycle-key-record", 1)
                trace.bytes("walk.cycle-key-text", visit.text)
                trace.bytes("walk.cycle-key-suffix", suffix)
                trace.bytes("walk.suffix-array", rest)
                pending = visit.text + rest
                trace.bytes("walk.expansion", pending)
                trace.vector("walk.expansion-vector-append", 1)
                trace.invoke("owned.pending-share-and-reset")
                cursor = 0
                expansion_count += 1
                if visit.text.startswith(b"/"):
                    trace.release("current")
                    trace.opaque("openat.root", "current", disposer="close",
                                 present=visit.failure != "ROOT")
                    if visit.failure == "ROOT":
                        break
                    stack.clear()
                    trace.invoke("owned.stack-clear")
                continue
            if name == b".." and final:
                if stack:
                    stack.pop()
                trace.invoke("owned.stack-pop")
            elif visit.kind != "DIRECTORY":
                if final and not rest:
                    result = WalkResult(visit.identity, b"/" + b"/".join(stack + [name]),
                                        count, directory=False)
                    final_component_count = len(stack) + 1
                    if transfer:
                        result = None  # an application root must be a directory
                break
            if final:
                if transfer:
                    c_name(trace, name, "walk.terminal-open-c-string")
                    trace.opaque("openat.terminal", "terminal", disposer="close",
                                 present=visit.failure not in {"OPEN", "ENAMETOOLONG"})
                    if visit.failure in {"OPEN", "ENAMETOOLONG"}:
                        if visit.failure == "ENAMETOOLONG":
                            trace.invoke("fpathconf")
                        break
                    trace.invoke("fstat.terminal")
                    if visit.failure not in {"HELD", "HELD_TYPE"}:
                        c_name(trace, name, "walk.terminal-recheck-c-string")
                        trace.invoke("fstatat.terminal-after")
                    if visit.failure in {"HELD", "HELD_TYPE", "NAMED", "CHANGED"}:
                        trace.release("terminal")
                        break
                    trace.release("current")
                    trace.ledger.transfer("terminal", Resource("current", "close"))
                components = stack + ([] if name == b".." else [name])
                result = WalkResult(visit.identity, b"/" + b"/".join(components), count)
                final_component_count = len(components)
                break
            c_name(trace, name, "walk.directory-open-c-string")
            trace.opaque("openat.directory", "next", disposer="close",
                         present=not visit.failure)
            if visit.failure:
                if visit.failure == "ENAMETOOLONG":
                    trace.invoke("fpathconf")
                break
            trace.release("current")
            trace.ledger.transfer("next", Resource("current", "close"))
            stack.append(name)
            trace.vector("walk.stack-append", 1)
        if result is not None:
            trace.vector("walk.final-component-vector", final_component_count)
            trace.bytes("walk.joined-resolved-without-leading-slash", result.resolved[1:])
            trace.bytes("walk.resolved", result.resolved)
            trace.vector("walk.spelling-and-expansion-records", expansion_count + 2)
        return result
    finally:
        if "current" in trace.ledger.resources:
            if result is not None and transfer:
                trace.ledger.transfer("current", Resource("root", "close"))
            else:
                trace.release("current")


def root_pair(trace: Trace, literal: bytes, before: tuple[Visit, ...], after: tuple[Visit, ...],
              *, resource: str = "TRUE") -> str:
    first = walk(trace, literal, before, transfer=True)
    if first is None:
        return "REFUSED"
    ordinary = len(first.resolved) <= 1023
    if ordinary:
        trace.bytes("root-resource.finalized-path", first.resolved + b"\0")
        trace.opaque("URL.construct.root", "root-url", disposer="ARC.release.root-url")
        trace.invoke("URL.resourceValues.isApplication", (
            Resource("root-values", "ARC.release.root-values"),
            Resource("root-error", "ARC.release.root-error"),
        ), ("root-error",) if resource == "ERROR" else ("root-values",))
        if resource != "ERROR":
            trace.receipts.append(Receipt("root-values.native-footprint", "opaque", None))
            trace.record("root-resource.swift-projection")
            trace.invoke("root-resource.optional-boolean-type-and-value")
            trace.release("root-values")
        else:
            trace.receipts.append(Receipt("root-error.native-footprint", "opaque", None))
            trace.release("root-error")
        trace.release("root-url")
        if resource == "TRUE":
            trace.invoke("metadata.reader-contract-boundary")  # supplied by k222
    trace.release("root")  # metadata owners must already have retired
    second = walk(trace, literal, after, transfer=False)
    if second is None or not second.directory or second.identity != first.identity:
        return "REFUSED"
    # Preserve first finalized spelling; the second is only a fresh identity observation.
    if not ordinary:
        return "INDEXED_REQUIRED"
    return "ORDINARY" if resource == "TRUE" else "METADATA_REFUSED"
