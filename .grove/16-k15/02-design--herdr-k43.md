# herdr-k43

## Goal

Design the terminal context and herdr state, geometry and operations.

## Context

- `herdr-evidence-k27`, `iterm-k41` and `provider-architecture-k5`.
- Requirement rows Terminal context, the four herdr rows and Integration
  setup, and "State for configured lists and on-screen labels".

## Done when

The spec, and an ADR where a decision clears the bar, state:

- the provider boundary;
- how the host session leads to the addressed herdr instance, and whether that
  needs cross-provider identity, decided under `provider-architecture`'s
  constraint;
- references and their containing scopes;
- list state, including unknown values;
- target geometry and its unavailable value;
- each operation's input, result, errors and authority, including which
  editor scrollback opens in and who chooses it;
- prerequisite discovery;
- the VM acceptance cases.
