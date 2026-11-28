# Provider authority follows effects

Koine divides the workflow extension into six providers: `desktop`,
`workspace`, `input`, `menus`, `iterm` and `herdr`. Each provider keeps the
independent read and control pair of the framework. The providers own these
effects:

- Desktop owns windows, displays, the pointer and system media.
- Workspace owns the discovery of applications and files, and launch, open and
  reveal.
- Input owns application input and bounded Space switching of the system.
- Menus owns the inspection, opening and invocation of application menus.
- iTerm and herdr own the operations of their addressed tools.

The [workflow spec](../specs/workflow-providers.md#authority-allocation)
defines the allocation of effects. These boundaries limit the authority of a
client. They are not isolation from the trusted native plugins.

An operation requires the ordinary authority of its provider **and every
additional authority that its effects require**. Immutable field metadata
declares the additional read and control capabilities of providers. The host
checks the complete conjunction before any mutation and at live dispatch
admission. This is an additive minor release of the framework, with the
required feature `additional-capabilities-v1`. Old registrations keep exactly
their existing meaning. The change adds no new capability class and no new
`koine-desktop/1` error kind.

For application-targeted operations, input and menus each resolve a captured
process incarnation independently, and each issues its own references. Before
they issue a reference, and again before an effect, they refuse Koine's own
process. Native UI control must not become a second route to the
local-console principal. Every other application is a target under the
capabilities, system consent and security UI included. Antony ruled this in
the design of app input, and the grant disclosures state that reach.

Input and menus never decode the remainder of a desktop reference. They never
focus a window to prepare an ordinary input or menu action. When a client
supplies the reference of another provider, the existing owner check of the
same class still applies. No exemption makes a desktop control reference
merely an input target.

Menus must discover and check each window-bound menu selection itself. When
menus cannot identify the selected target, it refuses. It does not retarget by
title.

The separation permits menu authority without input authority, and either one
without desktop control. Workspace launch, open and reveal also require desktop
control, because activation is an allowed effect. An iTerm or herdr primitive
declares the same additional requirement when its semantics or parameters
select activation or the focus of a desktop window. Native command submission
is not itself keystroke delivery. But a keystroke fallback needs input
authority, whatever the name of the public operation. A fallback that needs the
other authority cannot replace a required menu-only or input-only path.

These requirements cover every native action that Koine requests. That
includes hidden preparation, fallback and cleanup calls, and the documented
semantics of the primitive. Apply this test equally to all providers, also to
activation that the OS performs. The requirements do not sandbox the reaction
of an application to an authorised keystroke or menu invocation. An item may
itself open or focus a window.

Koine must not add its own focus call under menu or input authority. A
classification of arbitrary application reactions as separate Koine primitives
would make the authority of general menu invocation depend on runtime
behaviour. It would also defeat independent grants. The requirements record
Antony's acceptance of that reaction limit.

Bounded Space switching of the system deliberately selects a desktop effect,
so it requires both input control and desktop control. Pointer-button
synthesis is input wherever Koine exposes it. Pointer movement without held
buttons and system-media events stay desktop effects. The admitting field of an
interaction includes every cleanup mechanism in its static set. So revocation
cleanup cannot invent a new authority exemption.

## Trade-offs and alternatives

**One provider with only the existing control capability** would grant window
focus, input and menu invocation together. It fails the agreed separation.

**Finer named capabilities in one provider** could satisfy the separation. But
they would change the capability catalogue, enrolment, the UI and the field
model together. The six domains have useful private state and native adapters
of their own. Retain the two existing classes. Reconsider named capabilities if
real users need a subdivision within a domain. Examples are search without all
workspace reads, and pointer control without window control.

**A list of protected system prompts** would refuse consent, password and
security UI as targets of input and menus. Antony rejected it in the design of
app input, because he wants every application available under the
capabilities. The grant disclosures state that reach instead. Koine still
refuses itself, because a chord or a menu action in its Settings window could
approve a grant.

**Provider boundaries alone, with no additional requirements**, fail when one
operation crosses effect boundaries. A launch can activate an application, and
tool selection can focus a window. A rule that clients focus first cannot
establish authority for the activation that a later native call performs
itself. A dummy foreign reference, required only to obtain a second preflight
check, would expose policy mechanics as an artificial target protocol.

Static additional requirements hide that machinery, and they keep the
preflight of a mutation. Permission checks in provider code that depend on
runtime state would come too late to refuse a mixed mutation before its first
effect.

**Relaxing all foreign-reference checks to read authority** would silently
weaken existing operations. It still would not establish how one provider
resolves the private target of another. Independent capture costs separate
lookups and provider-local reference state. It keeps the existing composition
and opacity contracts.

A verified need to transfer a particular held native target between providers
would reopen this choice. It would do so through a separately specified
framework seam, not by parsing a URI remainder.

Raw filesystem search belongs to clients under the
[ownership decision](raw-filesystem-search-belongs-to-clients.md). The former
fixed find child and its cleanup are not a selected workspace feature. A native
discovery design must allocate its actual read mechanisms and its cleanup
explicitly. It must keep the source and binary evidence that actions cannot
reach discovery effects. The earlier find permission supplies no arbitrary
process control and no implicit catalogue backend.

Workspace is separate from desktop, so that existing desktop grants do not
acquire the authority to search the home directory and to open files. The
pointer, media and geometry additions of desktop do extend its provider-wide
control grant. This is an explicit trade-off of granularity. The requirements
separate input, menus and window focus, not every desktop effect.

Grant descriptions must disclose three reaches. They disclose the expanded
desktop authority before its additions ship. They disclose the broad launch
and document authority of workspace before workspace ships. They also disclose
the reach of input and menu grants. A document handler can execute a script or
follow a location document. Input to a terminal can execute commands, and
menus expose actions that the application defines.

The payload checks of workspace do not sandbox document contents or handler
reactions. The absence of a shell-execution API is not an application sandbox.
The loader and the build carry five additional provider bundles. OS
permissions, trust and the process failure domain stay shared.
