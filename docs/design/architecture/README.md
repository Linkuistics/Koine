# Architecture views

These editable views accompany the [desktop contract](../../specs/machine.md):
one resident application, the shared resilient Swift framework and bearer
credentials with live revocation. Koine implements that contract, and the spec's
"Test seams and acceptance" says what has been verified and what is still open.
"Agreed" in a diagram marks the contract the human approved; it does not mean
the part it labels is unbuilt.

[`index.html`](index.html) is a viewer that fetches the sources and exports
below, so it needs an HTTP server; nothing serves it by default. To read the
views with their captions, serve this directory and open the address it prints:

```sh
python3 -m http.server 8772 --bind 127.0.0.1 --directory docs/design/architecture
```

The SVG exports beside each source also open on their own.

Stable views:

- [Audited AX read and death ordering](index.html#diagram-process-admission) — adds the real read-only admission exchange, wrong-task control, death-before/between-effect schedules and actual PID reuse.
- [Direct AX effects](index.html#diagram-process-effects) — adds the executed read/effect/confirmation sequence, independent witness and post-death refusal.
- [Direct AX endpoint](index.html#diagram-process-endpoint) — retains the earlier retention/responder results and points to the newer admission and effect evidence; receiver ownership and policy remain open.
- [Native action binding](index.html#diagram-process-binding) — adds the signed/hardened private-token and data reconstruction counterexample, including a restore effect on a successor process.
- [Capture location](index.html#diagram-process-capture) — records the human's choice to preserve client-event capture; native transfer remains a candidate.
- [Public serial-number counterexample](index.html#diagram-process-serial) — shows the same serial naming a new process after automatic restoration, contrary to the agreed strict lifetime.
- [Resident application](index.html#diagram-packages) — shows runtime ownership.
- [Source packages](index.html#diagram-source-packages) — shows package dependencies separately.
- [Desktop interaction](index.html#diagram-addressing) — queries before choices and re-resolves before focus.
- [Authorization](index.html#diagram-machine-interface) — checks all actions before execution and authority again at admission.
- [Grant lifecycle](index.html#diagram-grants) — shows both grant workflows and revocation.
- [ABI decision](index.html#diagram-plugin-abi-options) — marks the shared Swift framework agreed and the C-compatible alternative not selected.
- [Native contributions](index.html#diagram-sdk-contributions) — explains shared Swift types, protocols and pre-load compatibility checks.

A graph starts at its marked "Start here" node. A sequence reads top to bottom;
a state diagram begins at a filled initial dot. Package views identify source
boundaries; the runtime view identifies the one resident application process.
Captions state limits, and no diagram constitutes formal verification.

## Sources and exports

Each source has a version-controlled SVG export. Edit sources, regenerate and
inspect exports. The renderer positions nodes; do not hand-edit generated SVG.
The installed toolchain is D2 0.9.0, PlantUML 1.2026.8 and Graphviz 16.1.0.
From this directory:

```sh
for diagram_source in desktop-composition.d2 machine-interface.d2 sdk-contributions.d2; do
  d2 --layout=tala --theme=0 --dark-theme=200 --pad=36 --timeout=30 \
    --tala-seeds=1,2,3 "$diagram_source" "${diagram_source%.d2}.svg"
done
d2 --layout=elk --theme=0 --dark-theme=200 --pad=36 \
  plugin-abi-options.d2 plugin-abi-options.svg
plantuml --svg --check-before-run --no-error-image packages.puml addressing.puml grants.puml
```

From the repository root, `task design:render-process-identity` renders the
process-capture, process-serial, process-binding, process-endpoint and
process-effects and process-admission views to their SVG exports and to PNGs under
`.build/design-identity`.

The viewer fetches sources and exports on reload; it does not compile them.
`diagrams.json` owns the topic outline, the captions and the introduction. The
process-identity views distinguish agreed constraints, rejected candidates and
open protocol work; they do not replace the current wire contract.
The serial-number view's deep link, rendering and topic/changed markers were
checked in Safari in a macOS 26.5 TestAnyware clone. Its native PNG export was
also inspected. This does not establish the other views' rendering, or mobile
and dark appearance.

The native action-binding view now shows the private reconstruction experiment;
the evidence report also retains the preceding public-held-object experiment.
Its PNG export and fresh-page deep link were checked in Safari in disposable
TestAnyware clone `koine-k56-binding`, including the topic outline, Current and
Updated markers and a wide desktop layout. Mobile and dark appearance were not
checked for this update. The host viewer serves the same source and manifest
at `http://127.0.0.1:8772/#diagram-process-binding`.

The original direct AX endpoint view recorded the port-lifetime and
responder-matching experiments. Its PNG, fresh-page deep link, discussion
panel, outline and Current/Updated markers
were checked in Safari in disposable clone `koine-k59-endpoint`. Wide light and
dark layouts and a narrow desktop window were inspected; no mobile device was
tested. The SVG retains its light canvas inside the dark viewer. The host
viewer serves the same SVG at
`http://127.0.0.1:8772/#diagram-process-endpoint`.

The later direct-effects view and revised endpoint note were rendered and
inspected in disposable clone `koine-k61-effects`. The new view's PNG and
fresh-page deep link, the discussion panel, outline and Current/Updated markers
were checked in Safari, including a wide light desktop window. The current
update was not checked on mobile or in dark appearance. The host viewer serves
the same sources and manifest at
`http://127.0.0.1:8772/#diagram-process-effects`.

The audited-read/death-ordering view's PNG and fresh-page deep link were checked
in Safari in disposable clone `koine-k63-admission`. The topic outline and
Current/Updated markers identify the intended revision; its wide light desktop
layout was inspected. Mobile and dark
appearance were not checked for this update. The endpoint and effects views
retain their original measurements and now point to the newer admission/death
evidence. The host viewer serves the same source and manifest at
`http://127.0.0.1:8772/#diagram-process-admission`.
