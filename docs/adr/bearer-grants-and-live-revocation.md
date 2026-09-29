# Bearer grants and live revocation

Clients present transferable opaque bearer credentials identifying persistent
Koine grants. Koine checks the live grant on every request; grants survive
restarts without automatic expiry and end through explicit revocation. Clients
keep secrets in Keychain or protected files. This supports both client-requested
approval and manual grant delivery through ordinary GraphQL clients, while making
credential possession sufficient to exercise the grant.

Binding grants to client cryptographic keys would prevent a copied token alone
from conferring access, but requires client key management and request signing.
Koine does not require that additional client protocol in `koine-desktop/1`.
A requirement for non-transferable client identity would reopen the decision;
changing it after clients ship requires a credential and protocol migration.
Client labels are display metadata, not authenticated executable identities.
