# Provider authority follows effects

Koine partitions the workflow extension into `desktop`, `workspace`, `input`,
`menus`, `iterm` and `herdr` providers. Each retains the framework's independent
read/control pair. Desktop owns windows, displays, pointer and system media;
workspace owns application/file discovery and launch/open/reveal; input owns
application input and bounded system Space switching; menus owns application-menu
inspection, opening and invocation; iTerm and herdr own their addressed tool
operations. The
[workflow spec](../specs/workflow-providers.md#authority-allocation) defines the
effect allocation. These are client authority boundaries, not isolation from
trusted native plugins.

An operation requires its provider's ordinary authority **and every additional
authority its effects require**. Immutable field metadata declares additional
provider read/control capabilities; the host checks the complete conjunction
before any mutation and at live dispatch admission. This is an additive
framework minor with required feature `additional-capabilities-v1`. Old
registrations retain exactly their existing meaning. No new capability class
or `koine-desktop/1` error kind is introduced.

Input and menus independently resolve a captured process incarnation and issue
their own references for application-targeted operations. They refuse Koine's
own process and recognized consent/security UI before issuance and effects;
native UI control must not become a second route to the local-console principal.
They never decode desktop reference remainders or focus
a window to prepare an ordinary input/menu action. Supplying another provider's
reference retains the existing same-class owner check. There is no exemption
that makes a desktop control reference merely an input target. Window-bound
menu selections must be discovered and validated by menus itself; inability to
identify the selected target is refusal, not title-based retargeting.

The separation permits menu authority without input authority and either
without desktop control. Meanwhile, workspace launch/open/reveal additionally
requires desktop control because activation is an allowed effect. An iTerm or
herdr primitive whose semantics or parameters select activation or desktop-window
focus declares the same additional requirement. Native command submission is
not itself keystroke
delivery, but a keystroke fallback needs input authority, however the public
operation is named. Required menu-only and input-only paths cannot be replaced
by fallbacks that need the other authority.

These requirements cover every native action Koine requests, including hidden
preparation, fallback and cleanup calls and the primitive's documented semantics.
Apply that test equally to all providers, including OS-performed activation.
They do not sandbox an application's reaction to an authorized keystroke or menu
invocation: an item may itself open or focus a window.
Koine may not add its own focus call under menu/input authority. Classifying
arbitrary application reactions as separate Koine primitives would make general
menu invocation's authority runtime-dependent and defeat independent grants.
The requirements record Antony's acceptance of that reaction limit. Bounded
system Space switching deliberately selects a desktop effect and requires both
input and desktop control. Pointer-button synthesis is input wherever exposed;
pointer movement without held buttons and system-media events remain desktop
effects. An interaction's admitting field includes all cleanup mechanisms in
its static set, so revocation cleanup cannot invent a new authority exemption.

## Trade-offs and alternatives

**One provider with only the existing control capability** would grant window
focus, input and menu invocation together. It fails the agreed separation.
**Finer named capabilities in one provider** could satisfy it but would change
the capability catalogue, enrollment, UI and field model together. The six
domains have useful private state and native adapters of their own; retain the
two existing classes. Reconsider named capabilities if real users need a
subdivision within a domain, such as search without all workspace reads or
pointer control without window control.

**Provider boundaries alone, with no additional requirements**, fail when one
operation crosses effect boundaries. A launch can activate; tool selection can
focus a window. Requiring clients to first focus cannot establish authority for
a later native call's own activation. Requiring a dummy foreign reference just
to obtain a second preflight check exposes policy mechanics as an artificial
target protocol. Static additional requirements hide that machinery while
preserving mutation preflight. Runtime-dependent permission checks in provider
code would be too late to refuse a mixed mutation before its first effect.

**Relaxing all foreign-reference checks to read authority** would silently
weaken existing operations and still would not establish how one provider
resolves another's private target. Independent capture costs separate lookups
and provider-local reference state; it preserves the existing composition and
opacity contracts. A verified need to transfer a particular held native target
between providers would reopen this choice through a separately specified
framework seam, not by parsing a URI remainder.

Workspace is separate from desktop so existing desktop grants do not acquire
home-directory search and file-opening authority. Desktop's pointer, media and
geometry additions do extend its provider-wide control grant. This is an
explicit granularity trade-off: the requirements separate input, menus and
window focus, not every desktop effect. Grant descriptions must disclose the
expanded desktop authority before its additions ship, workspace's broad
launch/document authority before workspace ships, and the reach of input and
menu grants. A document handler can execute a script or follow a location
document; input to a terminal can execute commands; menus expose
application-defined actions. Workspace's payload checks do not sandbox
document contents or handler reactions. The absence of a shell-execution API
is not an application sandbox. The loader and build carry five additional provider
bundles, while OS permissions, trust and the process failure domain remain shared.
