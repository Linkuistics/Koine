# Settings harness takes no keepalive captures

The Settings evaluation harness takes no periodic keepalive captures and has no
serialised keepalive command owner. It relies on the fixed host: macOS 27.2.1
(26B131) with Tart 2.42.0. The ordering evaluation pins both versions when it
freezes its subject. It does not rely on the TestAnyware VNC keeper, because the
next TestAnyware version removes it.

The keepalive captures existed only to avoid a Tart crash. With macOS 27.0.1 and
Tart 2.40.1, Tart crashed when a VNC client connected after 60 seconds or more
without one ([TestAnyware issue 2](https://github.com/Linkuistics/TestAnyware/issues/2)).
On 2026-11-21, TestAnyware reported that the fault does not reproduce on the
fixed versions after 70-second and 300-second gaps
([issue 13](https://github.com/Linkuistics/TestAnyware/issues/13)).
Its test is `task vm:tart-vnc-idle-repro`.

The rejected alternative was one serialised owner for scenario commands and
keepalive ticks, with an enforceable finite resource profile. Its
[design record](../verification/settings-activation/KEEPALIVE-DESIGN.md) and
[owner specification](../specs/settings-keepalive-owner.md) remain as history.
The owner was necessary only because keepalive captures collided with the
scenario's evidence writer. Its profile needed external evidence about
TestAnyware, Vision, kernel buffers and storage that no session could supply.
Antony first limited that profile to the resources that the owner controls,
then approved removing the keepalive itself.

The trade-off is a residual test-driver risk. The TestAnyware result is a finite
sample on one host. The evaluation allows no retry, so a crash during a guest
run is a test-driver failure that stops every later run. It is never a Koine
failure or a pass. Reopen this decision only if the crash reappears on the
pinned versions, or if the evaluation must use another host or Tart version.
