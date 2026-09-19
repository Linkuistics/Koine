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

    public init(coordinate: String, resolverId: String, authority: ProviderFieldAuthority) {
        self.coordinate = coordinate
        self.resolverId = resolverId
        self.authority = authority
    }
}

/// A provider can require only its own capabilities; it cannot mark a field
/// public or require management authority. Root `Mutation` actions require
/// `control`; a field a query can reach requires `read`.
public enum ProviderFieldAuthority: Sendable {
    case read
    case control
}
