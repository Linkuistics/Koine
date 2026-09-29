# Open-source release and Homebrew distribution

Koine is published as a public repository, `Linkuistics/Koine`, under
Apache-2.0, and distributed as a Homebrew cask from `Linkuistics/homebrew-taps`.
The release artifact is the Developer ID-signed, hardened-runtime application
bundle, notarized by Apple and stapled, attached to a tagged GitHub release; the
cask downloads it and installs it with no quarantine stripping, because a
notarized bundle needs none. Apple's notary service authenticates through a
stored keychain profile built from an App Store Connect API key, named by
`KOINE_NOTARY_PROFILE` with no fallback, in the same shape as the signing
identity.

The trade-off this settles is how a user obtains Koine. Koine is a
resident, per-user application holding Accessibility consent and a stable code
signature, so its designated requirement must never change across installs —
which makes hand-delivered builds a poor distribution channel and Gatekeeper's
treatment of a downloaded bundle part of the product rather than a packaging
detail. Notarizing and shipping through a cask makes the first-launch path a
verified one; it also makes the repository public, since a cask needs a publicly
reachable artifact and a licence has to accompany published source.

Koine does not keep its source closed and host the artifact elsewhere: that
buys the same install path at the cost of a hosting decision, and Koine's value
as a server third-party applications write providers against depends on those
authors being able to read the contract they compile against. Koine does not
ship the artifact without the tap, because the install path users follow would
then go unproven. Koine is not MIT-licensed: Apache-2.0 carries an explicit
patent grant, which matters for a published binary interface others compile
against, and is what every other public Linkuistics repository carries.

Reversal is limited: a published Apache-2.0 grant cannot be withdrawn from
versions already released.
