"""Pure observation model for reader policy; performs no native or target-file I/O."""
# pyright: strict

from __future__ import annotations

from collections.abc import Mapping, Sequence
from dataclasses import dataclass, field
from typing import cast


class MetadataRefusal(ValueError):
    """An observed object's affected metadata is unavailable."""


class PopulationExhaustion(RuntimeError):
    """A shared job limit requires FAILED/null publication."""


@dataclass(frozen=True)
class File:
    state: str = "ABSENT"
    size: int = 0
    values: dict[str, object] = field(default_factory=lambda: dict[str, object]())


@dataclass(frozen=True)
class NameOutcome:
    label: str | None = None
    refusal: str | None = None
    visited: tuple[tuple[str, str], ...] = ()


LAYOUTS = (
    ("Contents", "Contents/Resources"),
    ("Support Files", "Support Files/Resources"),
    ("Resources", "Resources"),
    (".", "."),
)
NAME_FILES = (
    "InfoPlist-macos.strings",
    "InfoPlist.strings",
    "InfoPlist-macos.loctable",
    "InfoPlist.loctable",
)
SHARED_FAILURES = frozenset({"COUNT_LIMIT", "CALL_LIMIT", "COPY_LIMIT", "DEADLINE"})


def checked_text(value: object, limit: int = 1024) -> str:
    if not isinstance(value, str) or "\0" in value:
        raise MetadataRefusal("STRING_TYPE_OR_NUL")
    try:
        size = len(value.encode("utf-8", errors="strict"))
    except UnicodeEncodeError as error:
        raise MetadataRefusal("STRING_ENCODING") from error
    if not 1 <= size <= limit:
        raise MetadataRefusal("STRING_BYTES")
    return value


def checked_dictionary(value: object) -> dict[str, object]:
    if not isinstance(value, dict):
        raise MetadataRefusal("DICTIONARY_TYPE")
    raw = cast(dict[object, object], value)
    if len(raw) > 4096:
        raise MetadataRefusal("DICTIONARY_KEYS")
    if any(not isinstance(key, str) for key in raw):
        raise MetadataRefusal("DICTIONARY_KEY_TYPE")
    return cast(dict[str, object], raw)


def observe_file(observation: File) -> dict[str, object] | None:
    if observation.state in SHARED_FAILURES:
        raise PopulationExhaustion(observation.state)
    if observation.state == "ABSENT":
        return None
    if observation.state != "REGULAR":
        raise MetadataRefusal(observation.state)
    if observation.size > 131072:
        raise MetadataRefusal("OVERSIZE")
    if observation.size < 0:
        raise MetadataRefusal("FILE_SIZE")
    return checked_dictionary(observation.values)


def choose_layout(states: Mapping[str, str]) -> tuple[str, str]:
    for information, resources in LAYOUTS:
        state = states.get(information, "DIRECTORY" if information == "." else "ABSENT")
        if state in SHARED_FAILURES:
            raise PopulationExhaustion(state)
        if state == "DIRECTORY":
            return information, resources
        if state != "ABSENT":
            raise MetadataRefusal(state)
    raise MetadataRefusal("ROOT_ABSENT")


def direct_inventory(
    entries: Sequence[str], states: Mapping[str, str], name_max: int | None
) -> tuple[str, ...]:
    inventory: list[str] = []
    for entry in entries:
        checked_text(entry)
        if not entry.endswith(".lproj"):
            continue
        if "/" in entry or name_max is None or name_max <= 0:
            raise MetadataRefusal("COMPONENT_LIMIT_OR_SYNTAX")
        if len(entry.encode("utf-8")) > name_max:
            raise MetadataRefusal("COMPONENT_BYTES")
        key = checked_text(entry[:-6])
        state = states.get(entry, "ABSENT")
        if state in SHARED_FAILURES:
            raise PopulationExhaustion(state)
        if state != "DIRECTORY":
            raise MetadataRefusal(state)
        inventory.append(key)
    selector_input(inventory, None)
    return tuple(inventory)


def selector_input(
    inventory: Sequence[str], development: str | None
) -> tuple[str, ...]:
    keys = [checked_text(key) for key in inventory]
    if len(keys) != len(set(keys)):
        raise MetadataRefusal("AMBIGUOUS_INVENTORY")
    ordered = sorted(keys, key=lambda key: key.encode("utf-8"))
    if development in ordered:
        ordered.remove(development)
        ordered.insert(0, development)
    return tuple(ordered)


def planned_keys(
    inventory: Sequence[str], development: str | None, returned: Sequence[str]
) -> tuple[str, ...]:
    possible = selector_input(inventory, development)
    selected: list[str] = []
    for raw in returned:
        key = checked_text(raw)
        if key not in possible:
            raise MetadataRefusal("FOREIGN_SELECTOR_KEY")
        if key not in selected:
            selected.append(key)
    for backstop in ("Base", development):
        if backstop is not None and backstop in possible and backstop not in selected:
            selected.append(backstop)
    return tuple(selected)


def read_information(files: Mapping[str, File]) -> dict[str, object] | None:
    for name in ("Info-macos.plist", "Info.plist"):
        dictionary = observe_file(files.get(name, File()))
        if dictionary is not None:
            return dictionary
    return None


def dictionary_name(dictionary: Mapping[str, object]) -> str | None:
    for key in ("CFBundleDisplayName", "CFBundleName"):
        value = dictionary.get(key)
        if key not in dictionary or value == "":
            continue
        return checked_text(value)
    return None


def table_name(
    table: dict[str, object], development: str | None, returned: Sequence[str] | None
) -> str | None:
    inventory: list[str] = []
    for key, value in table.items():
        if key == "LocProvenance":
            if isinstance(value, dict):
                checked_dictionary(cast(object, value))
            continue
        inventory.append(checked_text(key))
        if not isinstance(value, dict):
            raise MetadataRefusal("TABLE_VALUE_TYPE")
        checked_dictionary(cast(object, value))
    if inventory and returned is None:
        raise MetadataRefusal("SELECTOR_UNAVAILABLE")
    for key in planned_keys(inventory, development, returned or ()):
        dictionary = cast(dict[str, object], table[key])
        label = dictionary_name(dictionary)
        if label is not None:
            return label
    return None


def read_name(
    files: Mapping[tuple[str, str], File],
    bases: Sequence[str],
    information: Mapping[str, object] | None,
    development: str | None = None,
    table_returns: Mapping[tuple[str, str], Sequence[str]] | None = None,
    information_refusal: str | None = None,
) -> NameOutcome:
    visited: list[tuple[str, str]] = []
    try:
        for base in bases:
            for family in NAME_FILES:
                address = (base, family)
                visited.append(address)
                dictionary = observe_file(files.get(address, File()))
                if dictionary is None:
                    continue
                if family.endswith(".loctable"):
                    returned = (table_returns or {}).get(address)
                    label = table_name(dictionary, development, returned)
                else:
                    label = dictionary_name(dictionary)
                if label is not None:
                    return NameOutcome(label=label, visited=tuple(visited))
        if information_refusal is not None:
            return NameOutcome(refusal=information_refusal, visited=tuple(visited))
        return NameOutcome(
            label=dictionary_name(information or {}), visited=tuple(visited)
        )
    except MetadataRefusal as error:
        return NameOutcome(refusal=str(error), visited=tuple(visited))
