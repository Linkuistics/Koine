#!/usr/bin/env python3
"""Shows that the selection acceptance goes red against a subject that is wrong.

A control that has never been seen to fail is not a control (grove's rule for a
clean read). The decision scenarios of scripts/verify-selection-decisions.py all
pass against the loader as it is; this makes each of the instruments they rely on
come back dirty against a loader with one decision deliberately broken:

  * text comparison of versions          the numeric-precedence rows
  * a tie broken by the first copy       the tie rows, and the reversed discovery run
  * the signing-identifier check removed the identifier rows
  * reserved-name claims not refused     the claimant rows
  * an equal release taking over         the equal-and-older rows
  * every eligible candidate loaded      the never-ran markers
  * a host with no team given one        the ad-hoc host rows

and, for the failure boundary of scripts/verify-selection-failures.py:

  * two shipped selections not both refused on a principal conflict
  * an ordinary claimant of a principal not refused
  * a principal class of the host's own not counted as a conflict
  * the descriptor's features not compared with the manifest's
  * every eligible candidate loaded, after a frozen update fails

and, for the ordinary duplicates, the cascade and the start failure of the same driver:

  * a refused rival contesting an ordinary identity as an eligible one would
  * eligible ordinary duplicates not both refused
  * the capability-owner removal never run, run for one round only, or given no cycle
  * a provider that failed its start still answering as if it were running
  * every eligible candidate loaded, after a shipped provider fails its start

and, for the digest and restart rows of the same driver:

  * composition not keeping the shipped identities ahead of the ordinary ones, and
    composing them in reverse identifier order (the start order, the digest's positions)
  * a digest taken over the type names alone (changed SDL, a changed description)
  * every grant holding koine:manage
  * the assessment verdict never asked, and a refusal remembered across restarts
  * a per-user root that cannot be enumerated read as an empty one

and, for the update rows of scripts/verify-selection-updates.py:

  * an approval record's Team ID not compared with the host's, and no approval required
  * signatures not verified (an unsigned, ad-hoc or altered bundle, or a damaged staged copy)
  * a location that resolves outside the root not refused
  * the quarantine assessment of a per-user copy skipped
  * staging names that share a copy across origins (the earlier, content-only scheme)
  * the selection feature not required of a per-user update
  * the signing identifier not compared with the catalogue's (a fixture under another identifier)
  * compatibility (framework, feature, OS, architecture) not checked
  * every eligible candidate loaded (the unselected baseline's image mapped beside the update's)

Each mutation is applied to a COPY of the source tree (.build/selection-mutations/tree,
its own build directory, so later runs are incremental): the working tree is never
edited. The copy's headless host is assembled and signed into the same purpose-built
hosts, with this tree's fixtures and framework, and the named scenarios are run.
A mutation is seen when at least one host run of each named scenario fails.

usage: check-selection-mutations.py <fixtures> <output> [<mutation> ...]
Writes <output>/mutations.json; exits 1 if any mutation is not seen.
"""

import json
import os
import subprocess
import sys

REPOSITORY = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOADER = "Sources/KoineProviderLoader/"
TRUST = "Sources/KoineProviderLoader/ProviderTrust.swift"
STAGING = "Sources/KoineProviderLoader/ProviderStaging.swift"
CORE = "Sources/KoineCore/"

DRIVERS = {
    "decisions": "verify-selection-decisions.py", "failures": "verify-selection-failures.py",
    "updates": "verify-selection-updates.py",
}

# name -> (file, text to replace, replacement, scenarios of the driver that must go red[, driver]).
MUTATIONS = {
    "text-version-order": (
        LOADER + "ProviderCatalogue.swift",
        "(left.major, left.minor, left.patch) < (right.major, right.minor, right.patch)",
        "left.description < right.description",
        ["1.10.0 exceeds 1.9.0"],
    ),
    "tie-broken-by-first-copy": (
        LOADER + "ProviderSelection.swift",
        "if group.count == 1 {",
        "if group.count >= 1 {",
        ["a tied greatest group is refused"],
    ),
    "no-signing-identifier-check": (
        LOADER + "ProviderLoader.swift",
        "guard signer == baseline.signingIdentifier else {",
        "guard true || signer == baseline.signingIdentifier else {",
        ["falls back visibly to the bundle"],
    ),
    "reserved-claims-not-refused": (
        LOADER + "ProviderLoader.swift",
        "        if let entry = catalogue.entries.first(where: {\n            ProviderCatalogue.overlap(claimed",
        "        if false, let entry = catalogue.entries.first(where: {\n            ProviderCatalogue.overlap(claimed",
        ["claims-overlapping-prefix: refused alone before load, the owner present"],
    ),
    "equal-release-takes-over": (
        LOADER + "ProviderSelection.swift",
        "} else if release == baseline.release {",
        "} else if false && release == baseline.release {",
        ["equal and older copies never override the bundle"],
    ),
    "unselected-candidates-load": (
        LOADER + "ProviderLoader.swift",
        "if case .selected? = plan.verdicts[$0] { true } else { false }",
        "if case .selected? = plan.verdicts[$0] { true } else { prepared[$0] != nil }",
        ["a tie falls back to the verified bundle", "1.10.0 exceeds 1.9.0"],
    ),
    "host-without-team-is-given-one": (
        LOADER + "ProviderLoader.swift",
        "guard let hostTeam else {",
        'guard let hostTeam = Optional(hostTeam ?? "TA43A4RUP3") else {',
        ["an ad-hoc host admits no shipped candidate"],
    ),
    "shipped-conflict-not-symmetric": (
        LOADER + "ProviderLoader.swift",
        "if shipped.count > 1 {",
        "if false && shipped.count > 1 {",
        ["a shipped update and another shipped identity's bundle are refused symmetrically",
         "two shipped updates are equal slot owners"],
        "failures",
    ),
    "ordinary-claimant-not-refused": (
        LOADER + "ProviderLoader.swift",
        "for (candidate, _) in others { refused[candidate.id] = refused[candidate.id] ?? message }",
        "for (candidate, _) in others where false { refused[candidate.id] = refused[candidate.id] ?? message }",
        ["an ordinary claimant of a shipped principal is refused alone, the bundled owner running",
         "ordinary claimants of one principal are both refused"],
        "failures",
    ),
    "host-class-not-a-conflict": (
        LOADER + "ProviderLoader.swift",
        "if let existing = objc_lookUpClass(name), imagePath(of: existing) != ready.library {",
        "if false, let existing = objc_lookUpClass(name), imagePath(of: existing) != ready.library {",
        ["its principal class is one the host's own image registered", "its principal class is a system class",
         "an ordinary claimant of a host class is refused"],
        "failures",
    ),
    "descriptor-features-not-compared": (
        LOADER + "ProviderLoader.swift",
        "Set(descriptor.requiredFeatures) == Set(manifest.requiredFeatures)",
        "true",
        ["its descriptor disagrees with its manifest"],
        "failures",
    ),
    "alternatives-load-after-failure": (
        LOADER + "ProviderLoader.swift",
        "if case .selected? = plan.verdicts[$0] { true } else { false }",
        "if case .selected? = plan.verdicts[$0] { true } else { prepared[$0] != nil }",
        ["dlopen refuses its private dependency", "its principal class is one the host's own image registered"],
        "failures",
    ),
    "refused-rival-contests": (
        LOADER + "ProviderSelection.swift",
        "ordered.filter { $0.role == .ordinary && $0.isVerified }",
        "ordered.filter { $0.role == .ordinary }",
        ["a refused rival never evicts a valid ordinary provider: incompatible with this host's framework",
         "a refused rival never evicts a valid ordinary provider: ad-hoc signed",
         "a refused rival never evicts a valid ordinary provider: unapproved, claiming only the prefix"],
        "failures",
    ),
    "eligible-duplicates-not-refused": (
        LOADER + "ProviderSelection.swift",
        "if rivals.isEmpty {",
        "if true {",
        ["two eligible copies of one ordinary provider are both refused, and none loads",
         "two eligible providers that share only a prefix are both refused"],
        "failures",
    ),
    "cascade-never-removes": (
        CORE + "Composition.swift",
        "let stranded = composed.admitted.filter { !$0.additionalOwners.isSubset(of: present) }",
        "let stranded: [Candidate] = []",
        ["the third on that: its SDL does not parse", "the third on that: its principal class is one the host's own image registered"],
        "failures",
    ),
    "cascade-one-round-only": (
        CORE + "Composition.swift",
        "guard !stranded.isEmpty else { break }",
        "guard !stranded.isEmpty, !removed else { break }",
        ["the third on that: its SDL does not parse", "the third on that: its principal class is one the host's own image registered"],
        "failures",
    ),
    "cascade-no-cycle": (
        CORE + "Composition.swift",
        "let present = Set(composed.admitted.map(\\.providerId))",
        "let present = Set(composed.admitted.filter { $0.additionalOwners.isEmpty }.map(\\.providerId))",
        ["control: a valid dependency cycle between two shipped providers survives, with a third on it",
         "control: a dependant whose capability owner is present loads, and so does its dependant"],
        "failures",
    ),
    "failed-start-still-answers": (
        CORE + "ProviderLifecycle.swift",
        "guard case .started = state else {\n            return .failure(",
        "guard true else {\n            return .failure(",
        ["a shipped provider that fails its start keeps its schema and authority, strands nothing, and is not replaced",
         "a shipped provider that fails its start and has no dependants is not replaced by its bundled copy"],
        "failures",
    ),
    "alternatives-load-after-start-failure": (
        LOADER + "ProviderLoader.swift",
        "if case .selected? = plan.verdicts[$0] { true } else { false }",
        "if case .selected? = plan.verdicts[$0] { true } else { prepared[$0] != nil }",
        ["a shipped provider that fails its start keeps its schema and authority, strands nothing, and is not replaced",
         "a shipped provider that fails its start and has no dependants is not replaced by its bundled copy"],
        "failures",
    ),
    "composition-ignores-the-shipped-group": (
        CORE + "Composition.swift",
        "($0.active.origin == .bundled ? 0 : 1, $0.active.descriptor.providerId)\n"
        "                < ($1.active.origin == .bundled ? 0 : 1, $1.active.descriptor.providerId)",
        "($0.active.descriptor.providerId)\n                < ($1.active.descriptor.providerId)",
        ["an extra ordinary provider changes the digest"],
        "failures",
    ),
    "composition-in-reverse-identifier-order": (
        CORE + "Composition.swift",
        "($0.active.origin == .bundled ? 0 : 1, $0.active.descriptor.providerId)\n"
        "                < ($1.active.origin == .bundled ? 0 : 1, $1.active.descriptor.providerId)",
        "($0.active.origin == .bundled ? 0 : 1, $1.active.descriptor.providerId)\n"
        "                < ($1.active.origin == .bundled ? 0 : 1, $0.active.descriptor.providerId)",
        ["the same SDL from either root keeps the digest", "a catalogue listing the slots in another order"],
        "failures",
    ),
    "digest-over-type-names-only": (
        CORE + "CanonicalSDL.swift",
        "hex(SHA256.hash(data: Data(text(of: schema).utf8)))",
        'hex(SHA256.hash(data: Data(schema.typeMap.keys.sorted().joined(separator: ",").utf8)))',
        ["changed SDL in a newer copy changes the digest"],
        "failures",
    ),
    "every-grant-manages": (
        CORE + "Authority.swift",
        "            return Set(grant.capabilities)\n",
        "            return Set(grant.capabilities).union([CoreCapability.manage])\n",
        ["the same SDL from either root keeps the digest", "an extra ordinary provider changes the digest"],
        "failures",
    ),
    "quarantine-verdict-never-asked": (
        LOADER + "ProviderLoader.swift",
        "for image in images.sorted() where Gatekeeper.isQuarantined(image) {",
        "for image in images.sorted() where false && Gatekeeper.isQuarantined(image) {",
        ["a restart under a changed assessment verdict"],
        "failures",
    ),
    "refusal-remembered-across-restarts": (
        LOADER + "ProviderLoader.swift",
        "guard let reason = seam.assessment(image) else { continue }",
        'let kept = staged + ".refused"\n'
        "            let remembered = FileManager.default.fileExists(atPath: kept)\n"
        '            guard let reason = remembered ? "a refusal was kept from an earlier start, and" : seam.assessment(image)\n'
        "            else { continue }\n"
        "            FileManager.default.createFile(atPath: kept, contents: Data())",
        ["a restart under a changed assessment verdict"],
        "failures",
    ),
    "unreadable-root-read-as-empty": (
        LOADER + "ProviderLoader.swift",
        "let bundles = try FileManager.default\n"
        "                .contentsOfDirectory(at: root.location, includingPropertiesForKeys: nil)",
        "let bundles = ((try? FileManager.default\n"
        "                .contentsOfDirectory(at: root.location, includingPropertiesForKeys: nil)) ?? [])",
        ["a per-user root the host cannot read"],
        "failures",
    ),
    "approval-team-not-compared": (
        LOADER + "ProviderLoader.swift",
        "guard approval.teamIdentifier == hostTeam else {",
        "guard true || approval.teamIdentifier == hostTeam else {",
        ["an approval naming another Team ID refuses every per-user copy"],
        "updates",
    ),
    "approval-not-required": (
        LOADER + "ProviderLoader.swift",
        "let approval = try approval(for: manifest, role: role, in: root, hostTeam: hostTeam)",
        'let approval = (try? approval(for: manifest, role: role, in: root, hostTeam: hostTeam))\n'
        '                ?? ProviderApproval(providerId: manifest.providerId, teamIdentifier: hostTeam ?? "")',
        ["missing approval refuses every per-user copy", "an approval naming another Team ID refuses every per-user copy"],
        "updates",
    ),
    "signatures-not-verified": (
        TRUST,
        "static func refusal(of path: String, approvedBy approval: ProviderApproval) -> String? {",
        "static func refusal(of path: String, approvedBy approval: ProviderApproval) -> String? {\n        if true { return nil }",
        ["an unsigned bundle is refused before load", "an ad-hoc signed bundle is refused before load",
         "a seal altered after it was made is refused before load", "a staged copy damaged after it was made"],
        "updates",
    ),
    "location-not-checked": (
        LOADER + "ProviderLoader.swift",
        'guard let rootPath = canonicalPath(root.location.path), installed.hasPrefix(rootPath + "/")',
        'guard let rootPath = canonicalPath(root.location.path), installed.hasPrefix(rootPath + "/") || true',
        ["whose location resolves outside the root"],
        "updates",
    ),
    "quarantine-assessment-skipped": (
        LOADER + "ProviderLoader.swift",
        "if !root.isBundled {\n                try checkGatekeeper(",
        "if false && !root.isBundled {\n                try checkGatekeeper(",
        ["a failed quarantine assessment is refused before load", "a quarantine refusal is recovered"],
        "updates",
    ),
    "staging-shared-across-origins": (
        STAGING,
        'return "\\(name)-" + identity.prefix(16).map { String(format: "%02x", $0) }.joined()',
        'return "\\(name)-\\(try digest(of: bundle))"',
        ["equal bytes in both roots, the per-user copy staged first", "equal bytes in both roots, the bundled copy staged first",
         "a legacy shared staging entry", "a quarantined legacy entry"],
        "updates",
    ),
    "selection-feature-not-required": (
        LOADER + "ProviderLoader.swift",
        "!manifest.requiredFeatures.contains(firstPartySelectionFeature)",
        "!manifest.requiredFeatures.contains(firstPartySelectionFeature), false",
        ["update that does not state first-party-selection-v1 is refused before it loads",
         "real updates that do not state the feature are refused"],
        "updates",
    ),
    "no-signing-identifier-check-for-impostors": (
        LOADER + "ProviderLoader.swift",
        "guard signer == baseline.signingIdentifier else {",
        "guard true || signer == baseline.signingIdentifier else {",
        ["claiming the reserved pairs at a high release", "admits its own distinct fixture identifier"],
        "updates",
    ),
    "compatibility-not-checked": (
        LOADER + "ProviderLoader.swift",
        "try checkCompatibility(of: manifest, with: host)",
        "_ = try? checkCompatibility(of: manifest, with: host)",
        ["an incompatible framework is refused before load", "a feature this host lacks is refused before load",
         "a newer operating system is refused before load", "another architecture is refused before load"],
        "updates",
    ),
    "unselected-candidates-load-updates": (
        LOADER + "ProviderLoader.swift",
        "if case .selected? = plan.verdicts[$0] { true } else { false }",
        "if case .selected? = plan.verdicts[$0] { true } else { prepared[$0] != nil }",
        ["a mixed release: a newer desktop beside the workspace baseline",
         "a compatible newer workspace update beside the desktop baseline", "both real providers updated independently"],
        "updates",
    ),
}


def run(command, cwd, quiet=True):
    return subprocess.run(command, cwd=cwd, check=True, capture_output=quiet, text=True)


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    fixtures, output = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
    wanted = sys.argv[3:] or list(MUTATIONS)
    tree = os.path.join(REPOSITORY, ".build", "selection-mutations", "tree")
    os.makedirs(tree, exist_ok=True)
    os.makedirs(output, exist_ok=True)
    framework = run(["scripts/stage-provider-framework.sh", "debug"], REPOSITORY).stdout.strip()
    # The conformance tool is the unmutated tree's: the printer that takes the expected digest is never
    # the subject of a mutation, so a host's digest is held to a reference that cannot move with it.
    run(["swift", "build", "--product", "KoineConformance"], REPOSITORY)
    conformance = os.path.join(run(["swift", "build", "--show-bin-path"], REPOSITORY).stdout.strip(), "KoineConformance")
    report = {}
    for name in wanted:
        path, old, new, scenarios, *driver = MUTATIONS[name]
        driver = DRIVERS[driver[0] if driver else "decisions"]
        print(f"== {name}", flush=True)
        run(["rsync", "-a", "--delete", "--exclude", ".build", "--exclude", ".git", "--exclude", ".jj",
             "--exclude", ".grove", "--exclude", ".playwright-mcp", "--exclude", "node_modules",
             "./", tree + "/"], REPOSITORY)
        source = os.path.join(tree, path)
        with open(source) as file:
            text = file.read()
        if text.count(old) != 1:
            raise SystemExit(f"{name}: the text to mutate occurs {text.count(old)} times in {path}; the mutation is stale")
        with open(source, "w") as file:
            file.write(text.replace(old, new))
        run(["swift", "build", "--product", "KoineSelectionHost"], tree, quiet=False)
        products = run(["swift", "build", "--show-bin-path"], tree).stdout.strip()
        hosts = os.path.join(output, name, "hosts")
        run([os.path.join(REPOSITORY, "scripts/build-selection-hosts.py"), products, framework, fixtures, hosts], REPOSITORY)
        seen = {}
        for scenario in scenarios:
            results = os.path.join(output, name, "results.json")
            subprocess.run(
                [os.path.join(REPOSITORY, "scripts", driver), hosts, fixtures, results, "--only", scenario]
                + (["--conformance", conformance] if driver in (DRIVERS["failures"], DRIVERS["updates"]) else []),
                cwd=REPOSITORY, capture_output=True, text=True,
            )
            with open(results) as file:
                runs = json.load(file)["runs"]
            failed = [record["label"] for record in runs if not all(c["passed"] for c in record["checks"])]
            seen[scenario] = {"runs": len(runs), "failed": failed}
            print(f"   {scenario!r}: {len(failed)} of {len(runs)} host runs went red", flush=True)
        report[name] = seen
    ok = all(entry["failed"] for seen in report.values() for entry in seen.values())
    with open(os.path.join(output, "mutations.json"), "w") as file:
        json.dump(report, file, indent=1)
    print("every mutation was seen" if ok else "SOME MUTATION WAS NOT SEEN")
    sys.exit(0 if ok else 1)


main()
