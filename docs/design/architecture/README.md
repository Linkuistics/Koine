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

The viewer fetches sources and exports on reload; it does not compile them.
`diagrams.json` owns the topic outline, the captions and the introduction. The
viewer's layout in a browser, its anchors and its dark appearance have not been
checked; the SVG exports can be inspected on their own.
