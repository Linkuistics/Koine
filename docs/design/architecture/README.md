# Architecture views

Serve this directory over HTTP and open `index.html`; the viewer is Grove's
bundled static viewer and `diagrams.json` is its manifest. For example:

```sh
python3 -m http.server PORT --bind 127.0.0.1 --directory docs/design/architecture
```

The four views here were carried from ModalAnyware's architecture discussion
(commit d666016, plugin-packages-k6) when this project was created. Their
captions are written from ModalAnyware's point of view, say "Machine server"
where this project says Koine, and record what was agreed there. This
project's design sessions revise them; ModalAnyware keeps its own copies.
The query/execute and shared-framework views need reconciliation with
Koine's agreed GraphQL and native extension requirements; the
[current server boundary](../../adr/koine-server-and-native-providers.md)
records the requirements that take precedence.

Reading convention: every graph view marks its reading entry with a dark, bold
node whose label begins with "Start here" (the `start` class in each source)
and numbers its edges where the order matters; a sequence reads top to bottom
from its first message and a state diagram from the filled initial dot. Keep
the marker when adding or restructuring a view.

## Sources and exports

Every source has a corresponding `.svg` export, kept together in version
control. Edit the source, regenerate its export, then inspect the served view.
The toolchain the exports were made with is D2 0.9.0 (TALA layout), PlantUML
1.2026.8 and Graphviz 16.1.0; install with `brew install d2 plantuml`.

```sh
for diagram_source in machine-interface.d2 sdk-contributions.d2; do
  d2 --layout=tala --theme=0 --dark-theme=200 --pad=36 --scale=1 \
    --timeout=30 --tala-seeds=1,2,3 "$diagram_source" "${diagram_source%.d2}.svg"
done

plantuml --svg --check-before-run --no-error-image packages.puml addressing.puml
```

The viewer fetches sources and exports on reload but does not compile source
or detect stale exports. Diagram anchors are `#diagram-<id>` and stay stable
across title and renderer changes.
