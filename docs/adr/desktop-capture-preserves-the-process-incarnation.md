# Desktop capture preserves the process incarnation

The desktop target is the frontmost application sampled in the client's native
callback. Its continuously held, non-time identity denotes that OS process
incarnation; death or exec invalidating the identity ends the capture and its
references. A delayed callback after an app switch captures the new foreground
application; a switch after capture leaves the capture unchanged. Koine never
substitutes a later foreground application or restored process under an old
capture. Public client APIs, client-owned adapters, Koine-owned Accessibility
consent and no helper, injection or target cooperation remain required.

Capturing later at the server was rejected because it can select a different
application from the client's callback. PSN plus boot identity was rejected:
the [restoration counterexample](../verification/process-serial-lifetime.md)
preserves that pair while the OS process changes. Time and cached finite
PID/version fields do not provide the required non-colliding identity. The cost
of preserving the incarnation is actual native ownership and transfer, explicit
sample attribution and expiry, rather than a convenient portable process number.

Process identity does not alone bind an AX destination. The
[PID-recycling experiments](../verification/retained-ax-binding.md) exclude public
held AX wrappers and private token/data reconstruction as proof of an unchanged
endpoint. The independently chosen
[endpoint effect boundary](desktop-effects-use-the-admitted-endpoint.md) defines
what sends promise. Capture/transfer feasibility, reference/restart details and
adoption obligations live in the
[machine spec](../specs/machine.md#native-targeting-discussion).
