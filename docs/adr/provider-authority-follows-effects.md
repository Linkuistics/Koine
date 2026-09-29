# Provider authority follows effects

Koine partitions the workflow extension into `desktop`, `workspace`, `input`,
`menus`, `iterm` and `herdr` providers. Each retains the framework's independent
read/control pair. Desktop owns windows, displays, pointer and system media;
workspace owns application/file discovery and launch/open/reveal; input owns
keystroke delivery; menus owns application-menu inspection, opening and
invocation; iTerm and herdr own their addressed tool operations. The
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
their own references. They never decode desktop reference remainders or focus
a window to prepare an ordinary input/menu action. Supplying another provider's
reference retains the existing same-class owner check. There is no exemption
that makes a desktop control reference merely an input target. Window-bound
menu selections must be discovered and validated by menus itself; inability to
identify the selected target is refusal, not title-based retargeting.

The separation permits menu authority without input authority and either
without desktop control. Meanwhile, workspace launch/open/reveal additionally
requires desktop control because activation is an allowed effect. An iTerm or
herdr action that also activates or focuses a desktop window declares the same
additional requirement. Native command submission is not itself keystroke
delivery, but a keystroke fallback needs input authority, however the public
operation is named. Required menu-only and input-only paths cannot be replaced
by fallbacks that need the other authority.

These requirements cover every native action Koine requests, including hidden
preparation and fallback calls. They do not sandbox an application's reaction
to an authorized keystroke or menu invocation: an item may itself open a window.
Koine may not add its own focus call under menu/input authority. Classifying
arbitrary application reactions as separate Koine primitives would make general
menu invocation's authority runtime-dependent and defeat independent grants.

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
expanded desktop authority before the extension ships. The loader and build
now carry five additional provider bundles, while OS permissions, trust and
the process failure domain remain shared.
