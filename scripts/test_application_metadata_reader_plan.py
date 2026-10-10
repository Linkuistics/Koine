"""Counterexamples to fallback, inventory conflation and population poisoning."""
# pyright: strict

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import cast

import pytest
from application_metadata_reader_plan import (
    File,
    MetadataRefusal,
    PopulationExhaustion,
    choose_layout,
    direct_inventory,
    planned_keys,
    read_information,
    read_name,
    selector_input,
)


def test_direct_inventory_preserves_literal_names_and_parent_byte_bound() -> None:
    assert direct_inventory(
        ["Icon.icns", "en_AU.lproj", "français.lproj"],
        {"en_AU.lproj": "DIRECTORY", "français.lproj": "DIRECTORY"},
        15,
    ) == ("en_AU", "français")
    with pytest.raises(MetadataRefusal, match="COMPONENT_BYTES"):
        direct_inventory(["français.lproj"], {"français.lproj": "DIRECTORY"}, 14)


@pytest.mark.parametrize("state", ["DENIED", "SYMLINK", "WRONG_TYPE", "CHANGED"])
def test_rejected_locale_does_not_become_an_absent_language(state: str) -> None:
    with pytest.raises(MetadataRefusal):
        direct_inventory(["de.lproj"], {"de.lproj": state}, 255)


@pytest.mark.parametrize("component", [".lproj", "../de.lproj", "bad\0.lproj"])
def test_bad_locale_component_is_never_submitted(component: str) -> None:
    with pytest.raises(MetadataRefusal):
        direct_inventory([component], {component: "DIRECTORY"}, 255)


def test_indeterminate_parent_limit_cannot_assume_a_component_size() -> None:
    with pytest.raises(MetadataRefusal):
        direct_inventory(["en.lproj"], {"en.lproj": "DIRECTORY"}, None)


@pytest.mark.parametrize(
    ("states", "expected"),
    [
        ({"Contents": "DIRECTORY"}, ("Contents", "Contents/Resources")),
        ({"Support Files": "DIRECTORY"}, ("Support Files", "Support Files/Resources")),
        ({"Resources": "DIRECTORY"}, ("Resources", "Resources")),
        ({}, (".", ".")),
    ],
)
def test_checked_absence_selects_exact_layout(
    states: dict[str, str], expected: tuple[str, str]
) -> None:
    assert choose_layout(states) == expected


@pytest.mark.parametrize("state", ["DENIED", "SYMLINK", "WRONG_TYPE", "CHANGED"])
def test_bad_earlier_layout_never_uses_a_later_one(state: str) -> None:
    with pytest.raises(MetadataRefusal):
        choose_layout({"Contents": state, "Resources": "DIRECTORY"})


def test_positional_backstop_and_regional_returns_remain_literal() -> None:
    inventory = ["ar", "en_AU", "en_GB", "en", "it", "Base"]
    assert selector_input(inventory, "it") == (
        "it",
        "Base",
        "ar",
        "en",
        "en_AU",
        "en_GB",
    )
    assert planned_keys(inventory, "it", ["en_AU", "en_GB", "en", "en_AU"]) == (
        "en_AU",
        "en_GB",
        "en",
        "Base",
        "it",
    )


@pytest.mark.parametrize("returned", [["de"], ["en-AU"], ["LocProvenance"]])
def test_foreign_selector_results_cannot_map_by_normalizing(
    returned: list[str],
) -> None:
    with pytest.raises(MetadataRefusal):
        planned_keys(["en_AU"], None, returned)


def test_empty_inventory_skips_selector_and_duplicates_are_ambiguous() -> None:
    assert planned_keys([], "en", []) == ()
    with pytest.raises(MetadataRefusal):
        planned_keys(["en", "en"], "en", ["en"])


def test_present_empty_platform_information_is_authoritative() -> None:
    assert (
        read_information(
            {
                "Info-macos.plist": File("REGULAR", 20, {}),
                "Info.plist": File("REGULAR", 30, {"CFBundleName": "Wrong fallback"}),
            }
        )
        == {}
    )


@pytest.mark.parametrize(
    "state",
    [
        "DENIED",
        "MALFORMED",
        "SYMLINK",
        "SHORT_READ",
        "EXTRA_BYTE",
        "DATALLESS",
        "WRONG_TYPE",
        "UNSUPPORTED",
        "CHANGED",
        "OVERSIZE",
    ],
)
def test_bad_platform_information_cannot_fall_through(state: str) -> None:
    with pytest.raises(MetadataRefusal):
        read_information(
            {
                "Info-macos.plist": File(state),
                "Info.plist": File("REGULAR", 30, {"CFBundleName": "Wrong fallback"}),
            }
        )


def test_oversize_name_refuses_only_name_and_stops_before_rescue() -> None:
    result = read_name(
        {
            ("", "InfoPlist-macos.strings"): File("REGULAR", 131073),
            ("", "InfoPlist.strings"): File("REGULAR", 40, {"CFBundleName": "Wrong"}),
        },
        [""],
        {"CFBundleName": "Plain"},
    )
    assert result.label is None and result.refusal == "OVERSIZE"
    assert result.visited == (("", "InfoPlist-macos.strings"),)


def test_full_size_boundary_and_129_byte_name_are_usable() -> None:
    result = read_name(
        {
            ("", "InfoPlist-macos.strings"): File(
                "REGULAR", 131072, {"CFBundleName": "x" * 129}
            ),
        },
        [""],
        {},
    )
    assert result.label == "x" * 129 and result.refusal is None


def test_global_table_precedes_later_directory_strings_and_uses_own_inventory() -> None:
    table = ("", "InfoPlist.loctable")
    result = read_name(
        {
            table: File(
                "REGULAR",
                100,
                {
                    "LocProvenance": {"en": "metadata only"},
                    "de": {"CFBundleName": "Sprachmemos"},
                },
            ),
            ("en.lproj", "InfoPlist.strings"): File(
                "REGULAR", 40, {"CFBundleName": "Wrong"}
            ),
        },
        ["", "en.lproj"],
        {},
        table_returns={table: ["de"]},
    )
    assert result.label == "Sprachmemos"
    assert len(result.visited) == 4


@pytest.mark.parametrize(
    "family",
    [
        "InfoPlist-macos.strings",
        "InfoPlist.strings",
        "InfoPlist-macos.loctable",
        "InfoPlist.loctable",
    ],
)
def test_each_family_supplies_display_before_bundle_name(family: str) -> None:
    address = ("", family)
    values: dict[str, object] = {
        "CFBundleDisplayName": "Display",
        "CFBundleName": "Name",
    }
    if family.endswith(".loctable"):
        values = {"en": values}
    result = read_name(
        {address: File("REGULAR", 40, values)},
        [""],
        {},
        table_returns={address: ["en"]},
    )
    assert result.label == "Display"


def test_reserved_metadata_only_table_is_healthy_without_a_language() -> None:
    address = ("", "InfoPlist.loctable")
    result = read_name(
        {
            address: File(
                "REGULAR",
                40,
                {
                    "LocProvenance": {"en": {"CFBundleName": "Not a language"}},
                },
            )
        },
        [""],
        {"CFBundleName": "Plain"},
    )
    assert result.label == "Plain" and result.refusal is None


def test_missing_selector_observation_is_not_healthy_empty_selection() -> None:
    table = ("", "InfoPlist.loctable")
    result = read_name(
        {
            table: File(
                "REGULAR",
                30,
                {
                    "en": {"CFBundleName": "Localized"},
                },
            )
        },
        [""],
        {"CFBundleName": "Plain"},
    )
    assert result.label is None and result.refusal == "SELECTOR_UNAVAILABLE"


def test_healthy_empty_and_missing_keys_allow_next_family_then_plain_name() -> None:
    result = read_name(
        {
            ("", "InfoPlist-macos.strings"): File("REGULAR", 20, {}),
            ("", "InfoPlist.strings"): File("REGULAR", 20, {"CFBundleDisplayName": ""}),
            ("", "InfoPlist-macos.loctable"): File("REGULAR", 20, {}),
        },
        [""],
        {"CFBundleName": "Plain"},
    )
    assert result.label == "Plain" and result.refusal is None


def test_first_candidate_bundle_name_beats_later_display_name() -> None:
    result = read_name(
        {
            ("", "InfoPlist.strings"): File("REGULAR", 20, {"CFBundleName": "First"}),
            ("en.lproj", "InfoPlist.strings"): File(
                "REGULAR", 20, {"CFBundleDisplayName": "Later"}
            ),
        },
        ["", "en.lproj"],
        {},
    )
    assert result.label == "First"


@pytest.mark.parametrize("value", [12, "x" * 1025, "bad\0name"])
def test_malformed_display_cannot_bypass_to_bundle_name(value: object) -> None:
    result = read_name(
        {
            ("", "InfoPlist.strings"): File(
                "REGULAR",
                30,
                {
                    "CFBundleDisplayName": value,
                    "CFBundleName": "Wrong",
                },
            ),
        },
        [""],
        {"CFBundleName": "Plain"},
    )
    assert result.label is None and result.refusal is not None


def test_information_refusal_allows_independent_localized_name_but_no_plain_rescue() -> (
    None
):
    files = {("", "InfoPlist.strings"): File("REGULAR", 30, {"CFBundleName": "Local"})}
    assert read_name(files, [""], None, information_refusal="OVERSIZE").label == "Local"
    result = read_name({}, [""], None, information_refusal="OVERSIZE")
    assert result.label is None and result.refusal == "OVERSIZE"


@pytest.mark.parametrize(
    "state", ["COUNT_LIMIT", "CALL_LIMIT", "COPY_LIMIT", "DEADLINE"]
)
def test_shared_exhaustion_is_not_individual_metadata_refusal(state: str) -> None:
    with pytest.raises(PopulationExhaustion):
        read_name({("", "InfoPlist.strings"): File(state)}, [""], {})


def test_unselected_bad_table_value_and_dictionary_limit_refuse_object() -> None:
    table = ("", "InfoPlist.loctable")
    result = read_name(
        {
            table: File(
                "REGULAR",
                40,
                {
                    "en": {"CFBundleName": "Good"},
                    "de": "unsupported",
                },
            )
        },
        [""],
        {},
        table_returns={table: ["en"]},
    )
    assert result.label is None and result.refusal == "TABLE_VALUE_TYPE"
    with pytest.raises(MetadataRefusal, match="DICTIONARY_KEYS"):
        read_information(
            {
                "Info.plist": File(
                    "REGULAR", 131072, {str(index): "" for index in range(4097)}
                )
            }
        )


def object_map(value: object) -> dict[str, object]:
    assert isinstance(value, dict)
    assert all(isinstance(key, str) for key in cast(dict[object, object], value))
    return cast(dict[str, object], value)


def object_rows(value: object) -> list[dict[str, object]]:
    assert isinstance(value, list)
    return [object_map(row) for row in cast(list[object], value)]


def strings(value: object) -> list[str]:
    assert isinstance(value, list)
    assert all(isinstance(item, str) for item in cast(list[object], value))
    return cast(list[str], value)


@pytest.mark.parametrize("preferences", ["en-AU,en", "de"])
def test_every_saved_selector_plan_keeps_tables_and_alias_episodes(
    preferences: str,
) -> None:
    root = Path(__file__).resolve().parent.parent
    paths = [
        root / "docs/design/application-metadata-subject.json",
        root / "docs/design/application-metadata-budget-proposal.json",
        root / "scripts/application_metadata_reader_plan.py",
        Path(__file__),
    ]
    before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    subject = object_map(json.loads(paths[0].read_bytes()))
    proposal = object_map(json.loads(paths[1].read_bytes()))
    assert proposal["subjectSha256"] == before[paths[0]]
    observations = object_rows(subject["baseline"]) + object_rows(subject["fixtures"])
    by_path = {row["path"]: row for row in observations}
    run = object_map(object_map(proposal["selectionRuns"])[preferences])
    plans = object_rows(run["rows"])
    assert [row["path"] for row in plans] == subject["combinedEpisodes"]
    assert len(plans) == len(strings(subject["episodeSpellings"])) == 2043
    assert len(set(strings(subject["episodeSpellings"]))) == 2043
    for plan in plans:
        observed = by_path[plan["path"]]
        information = object_map(observed.get("information") or {})
        region = information.get("developmentRegion")
        development = region if isinstance(region, str) and region else None
        inventory = [locale[:-6] for locale in strings(observed["locales"])]
        keys = planned_keys(inventory, development, strings(plan["directSelected"]))
        assert [key + ".lproj" for key in keys] == plan["plannedBases"]
        tables = {
            row["relative"]: row
            for row in object_rows(observed["files"])
            if str(row["relative"]).endswith(".loctable")
        }
        saved_tables = object_rows(plan["tables"])
        assert [table["relative"] for table in saved_tables] == list(tables)
        for table_plan in saved_tables:
            table = tables[table_plan["relative"]]
            inventory = [
                key for key in strings(table["localeKeys"]) if key != "LocProvenance"
            ]
            assert (
                list(
                    planned_keys(
                        inventory, development, strings(table_plan["selected"])
                    )
                )
                == table_plan["plannedKeys"]
            )
            assert "LocProvenance" not in selector_input(inventory, development)
    after = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    assert before == after


@pytest.mark.parametrize(
    ("bundle", "language", "expected"),
    [
        ("FindMy", "en", "Find My"),
        ("FindMy", "de", "Wo ist?"),
        ("VoiceMemos", "en", "Voice Memos"),
        ("VoiceMemos", "de", "Sprachmemos"),
    ],
)
def test_saved_useful_name_values_need_loctable(
    bundle: str, language: str, expected: str
) -> None:
    path = (
        Path(__file__).resolve().parent.parent
        / "docs/design/application-metadata-subject.json"
    )
    subject = object_map(json.loads(path.read_bytes()))
    observed = next(
        row
        for row in object_rows(subject["baseline"])
        if row["path"] == f"/System/Applications/{bundle}.app"
    )
    table = next(
        row
        for row in object_rows(observed["files"])
        if str(row["relative"]).endswith("InfoPlist.loctable")
    )
    name = object_map(table["names"])[language]
    assert name == expected
    address = ("", "InfoPlist.loctable")
    # Controlled dictionary shape using a saved literal witness, not native parsing.
    values: dict[str, object] = {language: {"CFBundleName": name}}
    result = read_name(
        {address: File("REGULAR", int(str(table["bytes"])), values)},
        [""],
        {"CFBundleName": bundle},
        table_returns={address: [language]},
    )
    assert result.label == expected
    assert read_name({}, [""], {"CFBundleName": bundle}).label != expected
