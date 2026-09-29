# iterm-k41

## Goal

Design iTerm state, geometry, operations and prerequisite setup.

## Context

- `iterm-evidence-k26`'s findings, and any decision Antony made on the signing
  posture.
- `provider-architecture-k5`'s allocation and dependency classification.
- Requirement rows iTerm and Integration setup, and "State for configured
  lists and on-screen labels".

## Done when

The spec, and an ADR where a decision clears the bar, state:

- the provider boundary;
- tab and pane references and their lifetime;
- list state, including unknown values;
- pane geometry and its unavailable value;
- each operation's input, result, errors and authority;
- prerequisite discovery and the explicit setup operation;
- the VM acceptance cases.

The design exposes the session identity `herdr` will build its terminal
context on.
