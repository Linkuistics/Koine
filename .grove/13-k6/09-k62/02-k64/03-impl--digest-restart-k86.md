# digest-restart-k86

## Goal

Accept the schema-digest rows and the restart rows of the failure boundary at N
and G.

## Context

- The node brief `selection-failures-k64`: its "Digest" and "Restart"
  conditions, and Machine's rows "Same SDL across roots, changed SDL in newer
  copy, extra ordinary provider" and "Restart after update removal or changed
  baseline; changed assessment verdict; unreadable root".
- The harness library and restart machinery `freeze-failures-k84` leaves in
  `scripts/`, and `docs/verification/selection-failures.md`.
- The private `ProviderLoader.Seam.assessment` seam, for the injected verdict.

## Done when

The node brief's "Digest" and "Restart" conditions hold, Machine's two rows link
the evidence, and the node's "Machine's table links the evidence" condition is
met for every row this node owns.
