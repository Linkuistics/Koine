"""Controls for the design measurement instrument, not a Koine reader."""

import importlib.util
import plistlib
import sys
from pathlib import Path
from types import ModuleType

import pytest


def instrument() -> ModuleType:
    path = Path(__file__).with_name("application_metadata_subject.py")
    assert path.is_file(), "design measurement instrument is missing"
    spec = importlib.util.spec_from_file_location("metadata_subject", path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_indexed_regular_file_is_not_a_bundle(tmp_path: Path) -> None:
    path = tmp_path / "False.app"
    path.write_bytes(b"not a directory")
    row = instrument().measure_bundle(path)
    assert row["state"] == "NOT_DIRECTORY"
    assert "information" not in row


def test_locale_inventory_and_loctable_keys_are_independent(tmp_path: Path) -> None:
    root = tmp_path / "Witness.app"
    base = root / "Contents" / "Resources"
    (base / "en.lproj").mkdir(parents=True)
    (base / "unselected.lproj").mkdir()
    (base / "link.lproj").symlink_to(base / "en.lproj")
    (root / "Contents" / "Info.plist").write_bytes(
        plistlib.dumps({"CFBundleName": "Plain"})
    )
    (base / "InfoPlist.loctable").write_bytes(
        plistlib.dumps(
            {"en": {"CFBundleName": "Localized"}, "de": {"CFBundleName": "Deutsch"}}
        )
    )
    row = instrument().measure_bundle(root)
    assert row["locales"] == ["en.lproj", "unselected.lproj"]
    table = next(
        file
        for file in row["files"]
        if file["relative"] == "Contents/Resources/InfoPlist.loctable"
    )
    assert table["localeKeys"] == ["de", "en"]
    assert table["names"] == {"de": "Deutsch", "en": "Localized"}
    assert row["rejectedLocaleEntries"] == ["link.lproj"]


def test_repeated_spelling_charges_input_again(tmp_path: Path) -> None:
    root = tmp_path / "Witness.app"
    (root / "Contents" / "Resources").mkdir(parents=True)
    info = plistlib.dumps({"CFBundleName": "Plain"})
    (root / "Contents" / "Info.plist").write_bytes(info)
    row = instrument().measure_bundle(root)
    value = instrument().worksheet([row, row])
    assert value["informationInputBytes"] == 2 * len(info)
    assert value["bundleEpisodes"] == 2


def test_missing_known_name_file_fails_coverage_control(tmp_path: Path) -> None:
    with pytest.raises(AssertionError, match="loctable"):
        instrument().require_name_families(["InfoPlist.strings"])


def test_long_fixture_contents_do_not_use_whole_absolute_path(tmp_path: Path) -> None:
    root = tmp_path / ".build"
    while len(str(root).encode()) < 1400:
        root /= "a" * 100
    root /= "Fixture.app"
    module = instrument()
    module.create_bundle(root, "test.long", {"LSUIElement": False})
    row = module.measure_bundle(root)
    assert row["state"] == "DIRECTORY"
    assert row["information"]["identifier"] == "test.long"
    assert row["pathBytes"] > 1400


def test_malformed_xml_is_recorded_without_losing_file_dimensions(
    tmp_path: Path,
) -> None:
    data = b'<?xml version="1.0" encoding="UTF-16"?><plist><dict></plist>'
    (tmp_path / "InfoPlist.strings").write_bytes(data)
    row = instrument().measure_file(tmp_path, "InfoPlist.strings", "GLOBAL_NAME")
    assert row["bytes"] == len(data)
    assert row["parsed"] == "UNPARSED"


def test_root_alias_records_resolved_directory_separately(tmp_path: Path) -> None:
    target = tmp_path / "Actual.app"
    module = instrument()
    module.create_bundle(target, "test.alias", {})
    alias = tmp_path / "Alias.app"
    alias.symlink_to(target)
    row = module.measure_bundle(alias)
    assert row["path"] == str(alias)
    assert row["resolvedRoot"] == str(target)
