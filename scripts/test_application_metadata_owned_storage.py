"""Contract controls for explicit owned storage; no platform or target access."""
# pyright: strict

from __future__ import annotations

import importlib
import importlib.util
from pathlib import Path
from typing import Protocol, cast

import pytest
from application_metadata_operation_ledger import ContractViolation, Ledger, Limit


class StoreProtocol(Protocol):
    ledger: Ledger
    peak: int
    live: int

    def allocate(self, name: str, payload: int, *, header: int = 32) -> int: ...
    def write(self, name: str, size: int) -> None: ...
    def free(self, name: str) -> None: ...
    def vector(self, name: str, count: int, stride: int) -> int: ...
    def grow(self, name: str, count: int, stride: int, used: int) -> int: ...
    def inputs(self) -> None: ...
    def parsed(self, name: str) -> None: ...
    def retire_parser(self, name: str) -> None: ...
    def read_input(self, name: str, size: int, eof: int = 0) -> None: ...
    def project(self, size: int, bound: int, *, complete: bool = True) -> None: ...
    def cleanup(self) -> None: ...


class Model(Protocol):
    def Store(self, ledger: Ledger | None = None) -> StoreProtocol: ...
    def total(self, values: list[int | None]) -> int | None: ...
    def derive(self, root: Path) -> dict[str, object]: ...
    def compact(self, result: dict[str, object]) -> dict[str, object]: ...


def model() -> Model:
    # Missing feature must fail as an assertion, before import of the implementation.
    spec = importlib.util.find_spec("application_metadata_owned_storage")
    assert spec is not None, "explicit owned storage model is missing"
    return cast(Model, importlib.import_module("application_metadata_owned_storage"))


def test_capacity_header_and_population_are_separate_charges() -> None:
    store = model().Store()
    assert store.allocate("record", 24) == 64
    store.write("record", 24)
    assert store.ledger.spent_bytes == 64 + 32 + 24
    assert store.ledger.spent_attempts == 3
    store.cleanup()
    assert store.ledger.spent_bytes == 120  # freeing refunds neither bytes nor attempts
    assert store.ledger.spent_attempts == 4


def test_growing_vector_counts_old_live_copy_and_new_population() -> None:
    store = model().Store()
    assert store.vector("keys", 2, 8) == 48
    assert store.grow("keys", 4, 8, 2) == 64
    assert store.peak == 112
    assert store.ledger.spent_bytes == 48 + 32 + 16 + 64 + 32 + 16
    store.write("keys", 16)
    assert store.ledger.spent_bytes == 224
    store.cleanup()
    assert store.live == 0


def test_immutable_inputs_overlap_and_every_read_remains_charged() -> None:
    store = model().Store()
    store.inputs()
    before = store.ledger.spent_bytes
    store.read_input("information", 10)
    store.parsed("information")
    store.read_input("name", 11, 1)
    store.parsed("name")
    with pytest.raises(ContractViolation):
        store.read_input("information", 1)
    store.retire_parser("name")
    store.read_input("name", 12)
    assert store.ledger.spent_bytes == before + 10 + 11 + 1 + 12
    store.cleanup()
    assert store.ledger.spent_bytes == before + 34


def test_scalar_projection_charges_partial_prefix_without_retained_copy() -> None:
    store = model().Store()
    store.inputs()
    before = store.ledger.spent_bytes
    store.project(7, 1024, complete=False)
    assert store.ledger.spent_bytes == before + 7
    store.project(7, 1024)
    assert store.ledger.spent_bytes > before + 7 + 7 + 8
    with pytest.raises(ContractViolation):
        store.project(1025, 1024)
    store.cleanup()


def test_capacity_refusal_precedes_allocation_and_cleanup_still_fits() -> None:
    store = model().Store(Ledger(attempts=4, gross=120))
    store.allocate("first", 24)
    with pytest.raises(Limit):
        store.allocate("second", 24)
    assert "second" not in store.ledger.resources
    store.cleanup()
    assert store.ledger.spent_attempts == 3
    assert not store.ledger.slot_held


def test_every_optional_prefix_cleans_up_without_refund() -> None:
    for cap in range(1, 14):
        store = model().Store(Ledger(attempts=cap))
        try:
            store.vector("keys", 2, 8)
            store.grow("keys", 4, 8, 2)
            store.write("keys", 16)
        except Limit:
            pass
        spent = store.ledger.spent_bytes
        store.cleanup()
        assert store.ledger.spent_bytes == spent
        assert store.ledger.spent_attempts <= cap
        assert not store.ledger.slot_held


def test_unknown_terms_do_not_establish_zero_or_fit() -> None:
    assert model().total([12, None, 4]) is None
    assert model().total([12, 0, 4]) == 16


def test_compaction_preserves_every_cell_and_rejects_inconsistent_columns() -> None:
    feature = model()
    assert hasattr(feature, "compact"), "lossless per-item compaction is missing"
    result: dict[str, object] = {
        "episodeSpellings": ["/A.app", "/B.app"],
        "commonRows": [{"spelling": "/A.app", "unknown": None},
                       {"spelling": "/B.app", "unknown": 0}],
        "runs": {"de": {"rows": [{"spelling": "/A.app", "gross": 7},
                                  {"spelling": "/B.app", "gross": 9}]}},
    }
    saved = feature.compact(result)
    assert saved["episodeSpellings"] == ["/A.app", "/B.app"]
    assert saved["commonColumns"] == ["unknown"]
    assert saved["commonRows"] == [[None], [0]]
    assert saved["runs"] == {"de": {"columns": ["gross"], "rows": [[7], [9]]}}
    result["commonRows"] = [{"spelling": "/A.app"}, {"other": 7}]
    with pytest.raises(ValueError):
        feature.compact(result)


def test_every_saved_episode_and_outside_path_is_retained() -> None:
    result = model().derive(Path(__file__).resolve().parent.parent)
    from application_metadata_episode_certificate import objects, record, texts

    assert len(texts(result["episodeSpellings"])) == 2043
    assert len(objects(result["outsidePaths"])) == 149
    common = objects(result["commonRows"])
    assert sum(cast(int, row["locProvenance"]) for row in common) == 247
    assert max(cast(int, row["resolvedRootBytes"]) for row in common) == 1500
    assert max(cast(int, row["maximumObservedNameBytes"]) for row in common) == 129
    expected = {"en-AU,en": (14181924, 401979), "de": (14356031, 404815)}
    for key, run in record(result["runs"]).items():
        value = record(run)
        assert len(objects(value["rows"])) == 2043
        assert value["wholeJobGrossBytes"] is None
        assert value["wholeJobAttempts"] is None
        assert value["responseBytes"] is None
        assert value["knownLocalGrossBytes"] != 0
        assert (value["knownLocalGrossBytes"], value["knownLocalAttempts"]) == expected[key]
        assert cast(int, value["knownLocalGrossBytes"]) == (
            cast(int, result["sharedGross"])
            + sum(cast(int, row["knownLocalGrossUpper"]) for row in objects(value["rows"]))
        )
    assert result["nativeVerdict"] == "PENDING"
    assert result["usefulSubjectCertificateEstablished"] is False
