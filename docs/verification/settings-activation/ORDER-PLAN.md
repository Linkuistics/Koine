# Settings activation and window order comparison

Declared before the first guest on 2026-10-28. This is a new causal experiment,
separate from diagnostic 01/02 and from repair acceptance. Diagnostic 03 remains
prohibited by that sample's early-stop rule.

Hypothesis: requesting activation after makeKeyAndOrderFront can lose the native
activation opportunity; requesting it before window ordering may avoid that
condition. This does not presume a menu-tracking callback: the recorded callback
is in default run-loop mode after menu.didClose.

A is the unchanged diagnostic candidate; B moves the existing activate call and
its trace boundaries immediately before makeKeyAndOrderFront. No delay, retry,
second activation, focus action, policy change or new observer is added. The
trace itself retains its synchronous-write timing limitation in both arms.

Run exactly four fresh macOS 27.0.1/26A434 clones of the same golden image at
1920×1080: order-a 01, order-b 02, order-b 03, order-a 04. Each runs the existing
menu scenario's prefix through its initial Settings selection and three reopens,
with the same waits, input and focus assertion. Stop that attempt at its first
failure, collect untouched native/windows/screenshot/trace evidence, then stop
the clone. No replacement or extension for failure, transport loss or interruption.
Resize and all subsequent full-scenario assertions are outside this experiment.

The prefix is an exact copy of vm-verify-menu-bar.sh up to (excluding) the
TextEdit-quit command after the reopen loop, with only its repository-root cd
adjusted for the evidence directory. Task records the prefix exit separately
from Task's own exit. The capture wrapper is the k13 wrapper with new arm names
and the focused Task substituted. Its existing five mutation controls remain
the capture qualification; native behavior is established only in the guests.

Freeze each bundle's complete relative file/link inventory, actual consumed
scripts, Taskfile, manifests, source overlay, observer binary and golden
config/disk/NVRAM before collection; compare the same subjects afterwards.
Retain every started attempt and failed native transport independently of text
returned by that transport. Endpoint inventories establish no continuous
runtime immutability. Do not edit measured inputs during the four attempts.

A reproduced B failure rejects reversal as a sufficient repair. All-green B
alone establishes neither a cause nor a repair. If the experiment does not
discriminate a cause, keep the outcome unresolved and decompose the next precise
causal question; do not expand the cap. An application repair needs a separately
declared bounded complete fresh-guest sample with observation disabled, through
app:vm-verify-menu-bar. No release, notarization or upstream report is authorized.
