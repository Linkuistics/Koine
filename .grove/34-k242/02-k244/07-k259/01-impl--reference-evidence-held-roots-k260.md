# reference-evidence-held-roots-k260

## Goal

Implement a usable held-root and ordered-layout inspector on scratch directories,
with exact scope/race/no-contact evidence before any file acquisition.

## Context

Read the descriptor-relative ADR and durable held acquisition protocol. Use prior
schema/source occurrence records. This inspector uses test-only scratch handles;
packaging enforces the real selected /System, /Applications and /Library bounds.

## Work and verification

1. Freeze scratch trees/expectations for literal/resolved component scope, relative/
embedded-NUL/malformed spellings, /Applications-extra, outside link targets,
non-directory/file-alias slots, roots and ancestors replaced between checks.
2. Implement HeldAcquisition.swift and real descriptor/fault-seam tests. Resolve
root components with held search-only handles and kernel link/dot semantics.
Record original/resolved raw spelling, link observations and before/held/after
device/inode/type/available nanosecond stamps. Both scope checks precede listing/bytes.
3. Retain ancestry/root handles and compare named-versus-held identity before
descendants. Probe the closed information/resource layout pairs in order:
Contents / Contents/Resources; Support Files / Support Files/Resources;
Resources / Resources; root / root, using their exact contract component bytes.
Only established missing layout directories advance; denial/unknown/type/link/error
stops. Missing resource base cannot change selected information layout.
4. Prove with actual scratch syscalls and independently expected fault contact
traces that root/ancestor/base changes, descendant links and outside resolution
cause no forbidden listing or byte-open. Failure cannot reopen a newer root.
5. Add/verify task evidence:reference-held-root-check with per-probe states and
independent coordinate/reason/contact proof plus complete input/tool freeze.

## Done when

The inspector reports every ordered layout probe/selection/refusal with checked
scope/held identity and no forbidden content contact. Each outcome is schema-valid
and independently demonstrated. No file payload or stable package claim is fabricated.

## Notes

Keep kernel/no-atomic-snapshot limits explicit. Do not import a provider dependency
to reuse a walk.
