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

The k97 request-decoder update to the wire view was rendered with PlantUML
1.2026.8 in headless mode using `task design:render-process-identity`.
[Renderer/source hashes](../../verification/native-observation/request-render-before.sha256)
matched [after rendering](../../verification/native-observation/request-render-after.sha256).
The full PNG and a fresh Safari deep link, discussion, outline and updated
marker were inspected in disposable clone `koine-k94-preflight`. Wide light and
650-pixel light/dark desktop layouts were checked; the SVG retains its light
canvas, and narrow fit reduces text size with native-size/full-size alternatives
available. Viewer, manifest, changed source and SVG hashes matched guest/host;
host HTTP delivery matched. These are presentation checks, not an observation
exchange or a mobile-device check. Native byte inspection is documented in the
[request-decoder report](../../verification/native-observation-requests.md).

Stable views:

- [Native observation wire path and evidence gaps](index.html#diagram-process-observation-wire) — replaces missing request constants and decoder evidence with matched IDs, received-port checks and audit-field handoff; connection and complete receive validation remain open.
- [Observation admission and reference lifetime](index.html#diagram-process-observation) — proposed publication, split preparation outcomes, closure retirement and detected-loss withdrawal; native loss detection, read lifetime and cross-channel ordering remain unproved.
- [Native targeting guarantee boundaries](index.html#diagram-process-target-contract) — records agreed endpoint addressing, strict capture/reference expiry and explicitly permitted wrong-process effects.
- [Direct AX adoption and the contract decision](index.html#diagram-process-adoption) — distinguishes the revised contract from the unadopted adapter and remaining lifecycle, consent and protocol obligations.
- [Top-level AX descriptors and downstream effects](index.html#diagram-process-routing) — adds TextEdit's document/Open/Save observations, concrete AppKit callbacks and the downstream activation lifetime boundary.
- [Automatic restoration and AX client lifetime](index.html#diagram-process-restoration) — adds matched no-AX, single-read and direct-only client-retirement controls, with the bounded lifecycle conflict and unexecuted successor branches explicit.
- [AX receiver ownership and process transitions](index.html#diagram-process-receiver) — replaces the fixture-ambiguity note with the matched AX-contact result while retaining allocation, exec and routing evidence.
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
process-capture, process-serial, process-binding, process-endpoint,
process-effects, process-admission, process-receiver, process-restoration, process-routing, process-adoption, process-target-contract, process-observation and process-observation-wire views
to their SVG exports and to PNGs under
`.build/design-identity`.

The viewer fetches sources and exports on reload; it does not compile them.
`diagrams.json` owns the topic outline, the captions and the introduction. The
process-identity views distinguish agreed constraints, rejected candidates and
open protocol work; they do not replace the current wire contract.

The current proposal is [Observation and retirement protocol](../../specs/machine.md#observation-and-retirement-protocol-proposal).
The [native wire inspection](../../verification/native-observation.md) now maps
the registration/notification transport and freezes its runtime discriminator.
Static instruction evidence supplies no closure, loss detector or publication
barrier; the proposal below remains unchanged and unadopted.
The [layout dossier](../../verification/native-observation-layout.md) now derives
byte offsets and reply checks, with a bounded preflight for the uninspected
literals, server decoders and ownership links. `task design:decode-native-observation`
reproduces the saved-byte disassembly without executing native instructions.
The proposal distinguishes proven closure from preparation failure and detected loss,
requires evidence across both registration orders and separate reply/delivery
channels, and preserves read lifetime attribution despite the effect relaxation.
Bounded ingress validation precedes nonblocking send initiation; proven no-enqueue,
enqueued and ambiguous outcomes remain distinct. Unauthenticated input is
discarded; authenticated current-registration failure withdraws its dependent
records and fails affected listings. Recovery may use the same live capture with
new evidence and references. Reasons become generic after bounded reclamation;
the proposed provider-run allocator never wraps. Native feasibility, read
consequences, refusal/support costs and the complete protocol await agreement.
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

The receiver view's PNG export and fresh-page deep link were checked in Safari
in disposable clone `koine-k65-receiver`. The desktop light layout, topic outline
and Current/Updated markers identify the intended revision. Mobile and dark
appearance were not checked for this update. The host viewer serves the same
source and manifest at
`http://127.0.0.1:8772/#diagram-process-receiver`.

The [automatic-restoration view](index.html#diagram-process-restoration) adds the
matched controls and bounded AX-contact conflict; the
[receiver view](index.html#diagram-process-receiver) replaces its unresolved
fixture comparison with that result. Both PNG exports and fresh-page deep links
were inspected in Safari in disposable clone `koine-k69-restoration`. The topic
outline, discussion panel and Current/Updated markers match this revision.
The restoration view was checked in wide light and dark layouts and a 650-pixel
desktop window; the receiver update was checked in a wide dark layout. The SVGs
retain their light canvases inside the dark viewer. Narrow fit mode reduces
diagram text substantially; the full-size export and native-size option remain
available. No mobile device was tested. The host serves the same manifest at
`http://127.0.0.1:8772/#diagram-process-restoration`.

The [top-level routing view](index.html#diagram-process-routing) adds the local
descriptor/callback path and downstream effect boundary; the
[receiver view](index.html#diagram-process-receiver) now names those findings
and their remaining assumptions. Both PNG exports and fresh-page deep links
were checked in Safari in disposable clone `koine-k68-routing`. The discussion
panel, topic outline and Current/Updated markers match this revision. Desktop
light and dark appearance and a 650-pixel window were inspected; no mobile
device was tested. The SVGs retain a light canvas. Narrow fit mode substantially
reduces diagram text; native-size and full-size export remain available.
The host serves the same manifest at
`http://127.0.0.1:8772/#diagram-process-routing`.

The k72 revision of the [adoption view](index.html#diagram-process-adoption) named the bounded
window-qualified activation investigation, distinguishes stale-request refusal
from in-flight binding, and preserves the receiver/descriptor gap and agreed
rejection. The replacement and first release remain unresolved.
`task design:render-process-identity` completed with PlantUML 1.2026.8 and its
PNG was inspected. Safari in disposable TestAnyware clone `koine-k72-design`
rendered fresh-page deep links, the discussion panel, outline and Current/Updated
markers. Wide desktop light and 650-pixel desktop dark layouts were inspected;
the SVG retains its light canvas and the narrow view reduces text size. No mobile
device was tested. Guest hashes of the viewer, manifest, adoption source and SVG
match the host files; the host manifest and SVG match HTTP delivery at
`http://127.0.0.1:8772/#diagram-process-adoption`. These are presentation checks,
not a new native lifetime or consent experiment.

The [targeting contract view](index.html#diagram-process-target-contract) now
states the agreed endpoint-addressing boundary and its permitted wrong-process
effects. The [adoption view](index.html#diagram-process-adoption) now separates
that agreement from the unadopted mechanism and remaining protocol evidence.
The [addressing caption](index.html#diagram-addressing) identifies its sequence
as the served API whose receipt meaning still needs replacement. Final PNGs,
fresh-page deep links, discussion, outline and Current/Updated markers were
checked in Safari in disposable clone `koine-k78-final`. Desktop light views
and the targeting view in a 650-pixel dark window were inspected. SVG canvases
stay light; narrow fit mode reduces text size and retains native-size/full-size
alternatives. No mobile device was tested. Host and guest hashes matched for
the viewer, manifest, changed sources and SVGs; manifest and SVG HTTP hashes
matched too. The clone was stopped. These are presentation checks, with no
new native-binding evidence.

The observation view's k88 repairs were rendered with
`task design:render-process-identity` in disposable clone `koine-k88-design`.
The full PNG, Safari observation deep link, discussion summary, outline and
Current/Updated markers were inspected in desktop light appearance. No mobile
or dark-mode check is claimed. Viewer, manifest, source and SVG hashes matched
host/guest; HTTP manifest/SVG bytes matched the guest files. The clone was
stopped. These checks establish presentation only, not native feasibility.

The [native observation wire view](index.html#diagram-process-observation-wire)
adds the pinned static registration/delivery map and its unresolved native
premises. `task design:render-process-identity` completed with PlantUML 1.2026.8
in disposable clone `koine-k83-observation`, with unchanged renderer inputs.
The PNG, fresh-page Safari deep links, discussion panel, outline and
Current/Updated markers were inspected. Desktop light, wide dark and 650-pixel
dark layouts were checked; no mobile device was tested. The SVG retains its
light canvas, and narrow fit mode reduces text size; native-size and full-size
export remain available. Host/guest viewer, manifest, source and SVG hashes
matched, as did host HTTP delivery. The clone was stopped. The host serves the
checked view at `http://127.0.0.1:8772/#diagram-process-observation-wire`.
