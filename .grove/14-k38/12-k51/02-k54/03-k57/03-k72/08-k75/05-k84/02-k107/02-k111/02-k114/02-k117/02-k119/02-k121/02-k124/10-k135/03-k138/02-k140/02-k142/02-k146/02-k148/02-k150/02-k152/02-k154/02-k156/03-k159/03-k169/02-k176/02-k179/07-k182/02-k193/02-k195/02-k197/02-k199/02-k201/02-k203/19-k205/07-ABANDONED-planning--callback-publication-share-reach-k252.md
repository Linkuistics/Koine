# callback-publication-share-reach-k252

## Goal
Settle which ordinary-share and reserve boundaries a real file can attain,
before k229 builds B13, B14, B18 and the two reserve controls. State each one
with an attaining construction, or reclassify it with an infeasibility
argument and a labelled primitive.

## Context
publication-capacity.md "Frozen limits and reserve", "Concrete encoding" (row
maxima 11,609 / 12,973 / 6,145 / 2,049) and "Required-construction fit" (the
envelope-scale rows and their kind vectors). Also the k250 running log, the
B13/B14/B18 ledger rows, the k229 body and the k205 plan table in
callback-capture-transfer.md.

## Done when
- App byte share: say whether an app lane can reach 4 MiB of ordinary bytes
  within its kind caps (257 semantic, 81 commits and receipts, 641 begins) at
  real row sizes. K250's vector reaches 4,199,612 bytes only if 360 metadata
  rows are at the 2,049-byte maximum. Use k225's serializer sizes or a stated
  worst-case metadata row.
- Supervisor byte share: confirm or refute that 12 MiB is out of reach within
  its kind caps (about 5 MB at the row maxima). If so, B13 names only the
  resources it can test separately.
- Reserve tails: the 264-row app tail and the 196-row supervisor tail cannot
  both follow 1,536 ordinary rows. The 257-semantic cap and the 161-commit
  cap (80 terminal-unattempted commits plus ingress) prevent it. State which
  ordinary limit each reserve control follows and the largest tail a file can
  record after it. Say what "exercised with actual rows" in k229 means.
- B14: reserve exhaustion needs rows beyond any recordable tail. Choose a
  supplied-history construction (λ ≤ 428 on the startup ceiling), the
  failed-append variant alone, or a primitive, and give the argument.
- Update the ledger, the k250 fit rows if a vector changes (rerun
  `design:check-publication-profile`), the k229 bullets and the k205 plan
  table.

## Notes
Found while doing k250's path fit. That fit holds for every vector named here
whether or not the boundary is attainable. No control may be dropped or
weakened to incomplete-resource without its argument.
