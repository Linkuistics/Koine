# Workspace native images preserve action authority

Workspace packages a routing-only principal and independently linked actions,
discovery and settings images, with source and built-image guards on each. The
production action adapter is constructed privately inside WorkspaceActions;
the principal cannot inject an effect-capable replacement. Test substitution is
absent from production exports and linkage. Only Koine’s local explaining UI
reaches the settings image’s private conditional consent seam; no principal
GraphQL route can do so. The
[native contract](../specs/workspace-search.md#source-and-binary-authority-boundary)
and [workflow authority](provider-authority-follows-effects.md) define the
permitted routes and complete grants; these images remain in one trusted process,
sharing OS permissions and the failure domain. The discovery image alone owns
the narrowly approved component-relative fixed-file/direct-localization reader;
action/principal/shared lookup acquire no new contents code. Guards constrain
fixed paths and reachability as well as imports, so a generic scan using the same
syscalls is rejected.

Independent packaging, loader verification and guard instruments cost more than
one permissive image, but preserve the four accepted action paths while allowing
bounded native discovery and explicitly authorized settings effects. A single
image, or a clean action image with an injectable principal adapter, cannot
establish that actions cannot reach scripting, prompting or extra activation.
Reopen this boundary only if a replacement source and binary instrument can
reject those routes without weakening the existing action contract.
