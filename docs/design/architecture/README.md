# Koine architecture views

Open [the viewer](index.html) for the views, their outline and SVG/source
exports:

- [resident composition](index.html#diagram-packages) and
  [source packages](index.html#diagram-source-packages);
- [served desktop interaction](index.html#diagram-addressing);
- [authorization flow](index.html#diagram-machine-interface) and
  [grant lifecycle](index.html#diagram-grants);
- the [provider ABI choice](index.html#diagram-plugin-abi-options) and
  [SDK contributions](index.html#diagram-sdk-contributions).

The served desktop contract identifies a process by PID and kernel start instant
and uses public macOS Accessibility; the
[spec](../../specs/machine.md#native-targeting-discussion) lists the reuse races it
accepts. Graphs begin at their marked start node; sequences read top to bottom.
Captions state evidence limits. No diagram is formal verification or release
acceptance.

## Sources and exports

`diagrams.json` owns the introduction, captions and outline groups. Every view
has a PlantUML or D2 source with a version-controlled SVG export beside it.
Regenerate and inspect exports; do not hand-edit SVG. The viewer fetches sources
and exports on reload. PlantUML sources use PlantUML 1.2026.8; D2 sources use
D2 0.9.0 and Graphviz 16.1.0. Retain each source's existing renderer settings
when changing it.
