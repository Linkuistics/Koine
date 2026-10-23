# Workspace native images preserve action authority

## What binds now

Koine 0.4.0 ships the first cut of discovery. It reads two things and gives them to a client that holds `workspace:read`. They are Foundation's values for the special locations and the application list of the Spotlight index. It lists no directory, opens no file, runs no script and shows no consent prompt. Until System Settings scripting or the private application metadata reader arrives, this discovery code shares the workspace image with the four actions.

The cut keeps the action authority in three ways:

- Every field of a discovery query needs `workspace:read` and nothing else. Every action field keeps `workspace:control` and `desktop:control`. A grant of one set never reaches the other.
- The native adapter of the action code and of the discovery code is the same private seam. A discovery lookup calls no launch, open or reveal method, and a test records that. The application query also registers, resolves and inspects no application.
- The provider requires the host feature of [the disclosure decision](native-workspace-requires-disclosure-capable-host.md), so no host shows a read grant with less than its reach.

## What binds when scripting or the private reader arrives

Workspace packages four images. The principal image only routes. The actions, discovery and settings images link independently. Each image has source and built-image guards.

The production action adapter is constructed privately inside WorkspaceActions. The principal cannot inject an effect-capable replacement. Production exports and linkage contain no test substitution.

Only the local explaining UI of Koine reaches the private conditional consent seam of the settings image. No principal GraphQL route reaches it.

The [native contract](../specs/workspace-search.md#source-and-binary-authority-boundary) and the [workflow authority](provider-authority-follows-effects.md) define the permitted routes and the complete grants. The images remain in one trusted process. They share its OS permissions and its failure domain.

The discovery image alone owns the narrowly approved component-relative reader of fixed files and direct localisation names. The action image, the principal and the shared lookup acquire no new contents code. The guards constrain fixed paths and reachability as well as imports. A generic scan that uses the same syscalls is rejected.

Independent packaging, loader verification and guard instruments cost more than one permissive image. They preserve the four accepted action paths. They also allow bounded native discovery and explicitly authorised settings effects.

A single image cannot establish that actions cannot reach scripting, prompting or extra activation. A clean action image with an injectable principal adapter cannot establish it either. Reopen this boundary only if a replacement source and binary instrument can reject those routes without weakening the existing action contract.
