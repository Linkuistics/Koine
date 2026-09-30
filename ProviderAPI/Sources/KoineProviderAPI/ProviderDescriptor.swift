/// What a provider contributes: its identity, its schema SDL and one
/// registration for every field that SDL contributes.
public struct ProviderDescriptor: Sendable {
    /// The immutable provider identifier; also the prefix of its capabilities,
    /// `<providerId>:read` and `<providerId>:control`.
    public var providerId: String
    /// The GraphQL prefix of every type the provider contributes.
    public var graphQLPrefix: String
    public var schemaSDL: String
    public var fields: [ProviderFieldRegistration]
    /// Host features the provider cannot work without. A host lacking one
    /// refuses the whole contribution.
    public var requiredFeatures: [String]

    public init(
        providerId: String, graphQLPrefix: String, schemaSDL: String,
        fields: [ProviderFieldRegistration]
    ) {
        self.init(
            providerId: providerId, graphQLPrefix: graphQLPrefix, schemaSDL: schemaSDL,
            fields: fields, requiredFeatures: []
        )
    }

    public init(
        providerId: String, graphQLPrefix: String, schemaSDL: String,
        fields: [ProviderFieldRegistration], requiredFeatures: [String]
    ) {
        self.providerId = providerId
        self.graphQLPrefix = graphQLPrefix
        self.schemaSDL = schemaSDL
        self.fields = fields
        self.requiredFeatures = requiredFeatures
    }
}

/// Binds one schema coordinate (`Type.field`) to the resolver identifier the
/// provider receives for it and the provider capability the host enforces.
public struct ProviderFieldRegistration: Sendable {
    public var coordinate: String
    public var resolverId: String
    public var authority: ProviderFieldAuthority
    /// Further provider capabilities the field requires beside its own; empty
    /// for every registration made before framework minor 1. A descriptor that
    /// uses this declares `ProviderDescriptor.additionalCapabilitiesFeature`.
    public var additionalRequirements: [ProviderCapabilityRequirement]

    public init(coordinate: String, resolverId: String, authority: ProviderFieldAuthority) {
        self.init(
            coordinate: coordinate, resolverId: resolverId, authority: authority,
            additionalRequirements: []
        )
    }

    /// Framework minor 1. The set is immutable authority metadata: the host
    /// requires it wherever it requires `authority`.
    public init(
        coordinate: String, resolverId: String, authority: ProviderFieldAuthority,
        additionalRequirements: [ProviderCapabilityRequirement]
    ) {
        self.coordinate = coordinate
        self.resolverId = resolverId
        self.authority = authority
        self.additionalRequirements = additionalRequirements
    }
}

/// A provider can require only its own capabilities; it cannot mark a field
/// public or require management authority. Root `Mutation` actions require
/// `control`; a field a query can reach requires `read`.
public enum ProviderFieldAuthority: Sendable {
    case read
    case control
}

/// One provider capability a field requires in addition to its own: the
/// capability `<providerId>:read` or `<providerId>:control`. It names an
/// authority, never a call: a provider is not started, or ordered, by being
/// named. Core enrollment and management authority cannot be named.
public struct ProviderCapabilityRequirement: Sendable, Hashable {
    public enum Kind: Sendable, Hashable {
        case read
        case control
    }

    public var providerId: String
    public var kind: Kind

    public init(providerId: String, kind: Kind) {
        self.providerId = providerId
        self.kind = kind
    }
}

extension ProviderDescriptor {
    /// The required feature a descriptor declares when any registration carries
    /// additional requirements. A host that lacks it refuses the provider before
    /// loading; a host that has it refuses a descriptor that uses the
    /// requirements without declaring it.
    public static var additionalCapabilitiesFeature: String { "additional-capabilities-v1" }
}
