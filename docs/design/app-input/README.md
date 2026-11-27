# App input views

Open [the viewer](index.html#discussion) for the topic outline, the current
discussion, the editable sources and the SVG exports. Each graph begins at a
dark node labelled "Start here", and its numbered arrows give the order of the
steps. The contract that the views draw is the
[app input spec](../../specs/app-input.md).

Each view has a D2 source and an SVG export beside it. D2 0.9.0 renders them
with the Dagre layout, theme 0 and dark theme 200. Run
`task design:app-input-render` to regenerate the exports after a change to a
source, and do not edit an export by hand. Run
`task design:app-input-serve` to serve the views on loopback.
