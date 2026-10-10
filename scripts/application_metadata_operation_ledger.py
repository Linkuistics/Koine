"""Pure resource-accounting design model; no platform or target-file calls."""
# pyright: strict

from __future__ import annotations

from dataclasses import dataclass

from application_metadata_reader_plan import MetadataRefusal


class ContractViolation(ValueError):
    """A trace cannot establish the required lifetime or accounting contract."""


class Limit(RuntimeError):
    """Shared exhaustion freezes optional work before a platform invocation."""


@dataclass(frozen=True)
class Resource:
    name: str
    disposer: str
    dependencies: tuple[str, ...] = ()
    representation: str = "OPAQUE_NATIVE"


@dataclass(frozen=True)
class Pending:
    possible: tuple[Resource, ...]
    gross_upper: int


class Ledger:
    """One serial job's pure trace; budget reservation precedes every operation.

    Local allocate/copy/free events conservatively consume one attempt as well.
    This is a design upper bound, not a Swift allocator or platform-call counter.
    Native object footprint remains opaque; zero projected bytes proves no peak.
    """

    def __init__(self, attempts: int = 4194304, gross: int = 20971520) -> None:
        if attempts < 0 or gross < 0:
            raise ContractViolation("negative budget")
        self.attempt_limit = attempts
        self.gross_limit = gross
        self.spent_attempts = 0
        self.spent_bytes = 0
        self.resources: dict[str, Resource] = {}
        self.borrowed: dict[str, str] = {}
        self.operations: list[str] = []
        self.pending: Pending | None = None
        self.frozen: str | None = None
        self.slot_held = True

    def begin(
        self, operation: str, possible: tuple[Resource, ...] = (), gross_upper: int = 0
    ) -> None:
        if self.frozen is not None or self.pending is not None or not self.slot_held:
            raise ContractViolation("optional work after freeze, inflight call or true return")
        if gross_upper < 0 or len({item.name for item in possible}) != len(possible):
            raise ContractViolation("invalid reservation")
        for item in possible:
            if item.name in self.resources or any(
                name not in self.resources for name in item.dependencies
            ):
                raise ContractViolation("duplicate owner or absent backing dependency")
        if self.spent_attempts + len(self.resources) + 1 + len(possible) > self.attempt_limit:
            self.freeze("CALL_LIMIT")
            raise Limit("CALL_LIMIT")
        if self.spent_bytes + gross_upper > self.gross_limit:
            self.freeze("COPY_LIMIT")
            raise Limit("COPY_LIMIT")
        self.pending = Pending(possible, gross_upper)
        self.spent_attempts += 1
        self.operations.append(operation)

    def finish(self, acquired: tuple[str, ...] = (), bytes_written: int = 0) -> None:
        pending = self.pending
        if pending is None:
            raise ContractViolation("no actual call return")
        possible = {item.name: item for item in pending.possible}
        if (
            len(set(acquired)) != len(acquired)
            or not set(acquired).issubset(possible)
            or not 0 <= bytes_written <= pending.gross_upper
        ):
            raise ContractViolation("return outside reserved outputs or bytes")
        self.spent_bytes += bytes_written
        self.resources.update({name: possible[name] for name in acquired})
        self.pending = None  # only unspent reservations end; no spent charge decreases

    def call(self, operation: str) -> None:
        self.begin(operation)
        self.finish()

    def read(self, size: int) -> None:
        self.begin("pread", gross_upper=size)
        self.finish(bytes_written=size)

    def copy(self, size: int) -> None:
        self.begin("owned.copy", gross_upper=size)
        self.finish(bytes_written=size)

    def allocate(self, name: str, size: int, dependencies: tuple[str, ...] = ()) -> None:
        self.begin(
            "owned.allocate", (Resource(name, "owned.free", dependencies, "OWNED"),), size
        )
        self.finish((name,), size)

    def borrow(self, name: str, owner: str) -> None:
        if owner not in self.resources or name in self.borrowed:
            raise ContractViolation("absent owner or duplicate borrow")
        self.borrowed[name] = owner

    def end_borrow(self, name: str) -> None:
        if name not in self.borrowed:
            raise ContractViolation("absent borrow")
        del self.borrowed[name]

    def transfer(self, old: str, new: Resource) -> None:
        if (
            self.pending is not None or old not in self.resources
            or new.name in self.resources or old in self.borrowed.values()
            or any(old in item.dependencies for item in self.resources.values())
            or any(name not in self.resources or name == old for name in new.dependencies)
        ):
            raise ContractViolation("invalid ownership transfer")
        del self.resources[old]
        self.resources[new.name] = new  # same single reserved disposal, no second close

    def dispose(self, name: str) -> None:
        if (
            self.pending is not None or name not in self.resources
            or name in self.borrowed.values()
            or any(name in item.dependencies for item in self.resources.values())
        ):
            raise ContractViolation("in-use, borrowed, dependent or absent owner")
        item = self.resources.pop(name)
        self.operations.append(item.disposer)
        self.spent_attempts += 1  # already reserved before acquisition; allowed after freeze

    def freeze(self, reason: str) -> None:
        if self.frozen is None:
            self.frozen = reason

    def retire_all(self) -> None:
        """Unwind after a stage exits; pending calls and live borrowers still block."""
        if self.pending is not None or self.borrowed:
            raise ContractViolation("cannot unwind an inflight call or live borrow")
        while self.resources:
            children = {name for item in self.resources.values() for name in item.dependencies}
            available = [name for name in self.resources if name not in children]
            if not available:
                raise ContractViolation("cyclic owner dependency")
            self.dispose(available[-1])

    def return_slot(self) -> None:
        if self.pending is not None or self.resources or self.borrowed or not self.slot_held:
            raise ContractViolation("true return before complete disposal")
        self.slot_held = False


FILE_BRANCHES = frozenset({
    "PARENT_LIMIT_REFUSED", "ABSENT", "NAMED_REFUSED", "OVERSIZE_NAMED", "OPEN_FAILED",
    "HELD_REFUSED", "OVERSIZE_HELD", "READ_ERROR", "SHORT_READ", "EOF_ERROR", "EOF_EXTRA",
    "HELD_CHANGED", "NAMED_CHANGED", "OK",
})


def file_trace(ledger: Ledger, branch: str, size: int) -> None:
    """Concrete fixed-file syscall branches; input buffer belongs to the caller.

    Classification/size/stamp comparisons are local. No retry, parser, extra
    read or descendant pathname is performed. Names here are trace labels only.
    """
    if branch not in FILE_BRANCHES or size < 0 or (size == 0 and branch == "SHORT_READ"):
        raise ContractViolation("invalid fixed-file trace")
    ledger.call("fpathconf")
    if branch == "PARENT_LIMIT_REFUSED":
        return
    ledger.call("fstatat.before")
    if branch in {"ABSENT", "NAMED_REFUSED", "OVERSIZE_NAMED"}:
        return
    ledger.begin("openat", (Resource("file", "close"),))
    ledger.finish(() if branch == "OPEN_FAILED" else ("file",))
    if branch == "OPEN_FAILED":
        return
    ledger.call("fstat.before")
    if branch not in {"HELD_REFUSED", "OVERSIZE_HELD"}:
        ledger.begin("pread.payload", gross_upper=size)
        payload = 0 if branch == "READ_ERROR" else size - (branch == "SHORT_READ")
        ledger.finish(bytes_written=payload)
        if branch not in {"READ_ERROR", "SHORT_READ"}:
            ledger.begin("pread.eof", gross_upper=1)
            ledger.finish(bytes_written=int(branch == "EOF_EXTRA"))
            if branch not in {"EOF_ERROR", "EOF_EXTRA"}:
                ledger.call("fstat.after")
                if branch != "HELD_CHANGED":
                    ledger.call("fstatat.after")
    ledger.dispose("file")


def listing_trace(ledger: Ledger, branch: str) -> None:
    """fdopendir transfers the dup only on success; failure retains caller ownership."""
    if branch not in {"FAILED", "EOF", "READDIR_ERROR"}:
        raise ContractViolation("invalid listing trace")
    ledger.begin("dup", (Resource("listing_fd", "close"),))
    ledger.finish(("listing_fd",))
    ledger.call("fdopendir")
    if branch == "FAILED":
        ledger.dispose("listing_fd")
        return
    ledger.transfer("listing_fd", Resource("dir", "closedir"))
    ledger.call("readdir")  # terminal EOF/error attempt is charged even with no slot
    ledger.dispose("dir")


def parser_trace(ledger: Ledger, branch: str) -> None:
    """All parser return shapes, with data-before-buffer lifetime; no parsing occurs."""
    if branch not in {"DATA_NIL", "NIL_NO_ERROR", "ERROR", "BOTH", "WRONG_TYPE", "KEY_LIMIT", "OK"}:
        raise ContractViolation("invalid parser trace")
    ledger.begin("CFDataCreateWithBytesNoCopy", (Resource("data", "CFRelease", ("buffer",)),))
    ledger.finish(() if branch == "DATA_NIL" else ("data",))
    if branch == "DATA_NIL":
        return
    ledger.begin("CFPropertyListCreateWithData", (
        Resource("plist", "CFRelease", ("data",)), Resource("error", "CFRelease"),
    ))
    outputs: tuple[str, ...]
    if branch == "NIL_NO_ERROR":
        outputs = ()
    elif branch == "ERROR":
        outputs = ("error",)
    elif branch == "BOTH":
        outputs = ("plist", "error")
    else:
        outputs = ("plist",)
    ledger.finish(outputs)
    if "error" in outputs:
        ledger.dispose("error")  # do not copy an arbitrary native error description
    if "plist" in outputs:
        if branch != "BOTH":
            ledger.call("CFGetTypeID")
            if branch != "WRONG_TYPE":
                ledger.call("CFDictionaryGetCount")
        ledger.dispose("plist")
    ledger.dispose("data")


def returned_keys_trace(
    ledger: Ledger, possible: tuple[str, ...], returned: tuple[str, ...]
) -> tuple[str, ...]:
    """Each raw returned slot is inspected/charged before exact mapping and dedup."""
    selected: list[str] = []
    for key in returned:
        ledger.call("CFArrayGetValueAtIndex")
        ledger.call("CFGetTypeID")
        ledger.call("CFStringGetLength")
        ledger.call("CFStringGetMaximumSizeForEncoding")
        size = len(key.encode("utf-8"))
        ledger.begin("CFStringGetBytes", gross_upper=size)
        ledger.finish(bytes_written=size)
        if key not in possible:
            raise MetadataRefusal("FOREIGN_SELECTOR_KEY")
        if key not in selected:
            selected.append(key)
    return tuple(selected)
