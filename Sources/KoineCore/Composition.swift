import GraphQL
import KoineProviderAPI

/// Why a provider's contribution was refused, or what went wrong with an active
/// one. Served as provider status by management.
public struct ProviderDiagnostic: Sendable, Equatable {
    public enum Reason: String, Sendable {
        case invalidIdentity
        case reservedName
        case duplicateIdentifier
        case nameCollision
        case missingPrefix
        case invalidSDL
        case foreignTypeExtension
        case missingResolver
        case unclassifiedField
        case unknownCoordinate
        case actionOutsideMutation
        case unsupportedFeature
        /// The descriptor uses additional capability requirements without
        /// declaring the feature that carries them.
        case undeclaredFeature
        /// A field requires a capability of a provider that is not admitted, or
        /// names an authority no provider field may require.
        case invalidCapabilityRequirement
        case missingCapabilityOwner
        case introspectionLimit
        /// An active provider did not recognise a registered resolver.
        case resolverMismatch
    }

    public let providerId: String
    public let reason: Reason
    public let message: String

    public init(providerId: String, reason: Reason, message: String) {
        self.providerId = providerId
        self.reason = reason
        self.message = message
    }
}

/// The host feature every newly published first-party update declares, so that
/// an earlier host refuses it before `dlopen`. It is a host selection feature,
/// not a framework declaration (docs/specs/machine.md, "Eligibility and
/// precedence"); the native loader states the same name.
public let firstPartySelectionFeature = "first-party-selection-v1"

/// Host features a provider may require: `additional-capabilities-v1`, carried by
/// framework minor 1 (docs/specs/machine.md, "Additional capability requirements"),
/// and `first-party-selection-v1`, which needs no framework minor.
public let koineHostFeatures: Set<String> = [
    ProviderDescriptor.additionalCapabilitiesFeature, firstPartySelectionFeature,
]

/// An identifier and prefix reserved to a shipped provider. Names beneath a
/// reserved identity belong to that shipped provider alone, whether or not it
/// is present, admitted or started (docs/specs/machine.md, "Reserved identities").
public struct ReservedIdentity: Sendable, Equatable {
    public let providerId: String
    public let graphQLPrefix: String

    public init(providerId: String, graphQLPrefix: String) {
        self.providerId = providerId
        self.graphQLPrefix = graphQLPrefix
    }

    /// Before a host states its catalogue, the desktop provider's identity is
    /// the one reservation a composition makes.
    public static let desktopOnly = [ReservedIdentity(providerId: "desktop", graphQLPrefix: "Desktop")]
}

/// Composes provider contributions onto the core schema
/// (docs/specs/machine.md, "Composition and operation placement"). A provider is
/// published whole or refused whole, and the outcome does not depend on the
/// order the providers were given in.
struct Composition {
    let schema: GraphQLSchema
    let accepted: [ProviderContribution]
    let diagnostics: [ProviderDiagnostic]


    /// `admits` answers whether a candidate schema may be served; a provider
    /// whose addition it rejects is refused.
    init(
        core: GraphQLSchema, providers: [ActiveProvider], policy: RequestPolicy,
        reserved: [ReservedIdentity] = ReservedIdentity.desktopOnly, admits: (GraphQLSchema) -> Bool
    ) {
        var diagnostics: [ProviderDiagnostic] = []
        var candidates: [Candidate] = []
        var identityReserved: Set<Int> = []
        for (index, active) in providers.enumerated() {
            do {
                candidates.append(
                    try Candidate(
                        index: index, active: active, core: core, policy: policy, reserved: reserved
                    )
                )
            } catch let refusal as Refusal {
                diagnostics.append(refusal.diagnostic(for: active))
                if refusal.reservedIdentity { identityReserved.insert(index) }
            } catch {
                diagnostics.append(
                    Refusal(.invalidSDL, "The contribution could not be checked.")
                        .diagnostic(for: active)
                )
            }
        }

        // A reserved identity never competes. Every other claim does, even one
        // already refused: no winner is chosen among competing claims.
        let claimants = providers.enumerated().filter { !identityReserved.contains($0.offset) }
        var contested: Set<Int> = []
        for (index, active) in claimants {
            let rivals = claimants.filter {
                $0.offset != index
                    && ($0.element.descriptor.providerId == active.descriptor.providerId
                        || $0.element.descriptor.graphQLPrefix == active.descriptor.graphQLPrefix)
            }
            guard !rivals.isEmpty else { continue }
            contested.insert(index)
            if candidates.contains(where: { $0.index == index }) {
                diagnostics.append(
                    Refusal(
                        .duplicateIdentifier,
                        "Another provider claims this identifier or prefix; both are refused."
                    ).diagnostic(for: active)
                )
            }
        }
        candidates.removeAll { contested.contains($0.index) }

        var claimCounts: [String: Int] = [:]
        for candidate in candidates {
            for name in candidate.claimedNames { claimCounts[name, default: 0] += 1 }
        }
        candidates.removeAll { candidate in
            let shared = candidate.claimedNames.filter { claimCounts[$0, default: 0] > 1 }.sorted()
            guard let name = shared.first else { return false }
            diagnostics.append(
                Refusal(.nameCollision, "Another provider also defines \(name); both are refused.")
                    .diagnostic(for: candidate.active)
            )
            return true
        }

        // A canonical order: root fields keep declared order in the schema, so
        // the order of composition is part of what the digest covers.
        candidates.sort {
            ($0.active.origin == .bundled ? 0 : 1, $0.active.descriptor.providerId)
                < ($1.active.origin == .bundled ? 0 : 1, $1.active.descriptor.providerId)
        }
        /// Extends the core with each candidate in order; one that does not
        /// fit is refused whole and the rest go on.
        func compose(
            _ list: [Candidate], admits: (GraphQLSchema) -> Bool
        ) -> (schema: GraphQLSchema, admitted: [Candidate]) {
            var schema = core
            var admitted: [Candidate] = []
            for candidate in list {
                do {
                    let extended = try extendSchema(schema: schema, documentAST: candidate.document)
                    if let invalid = validateSchema(schema: extended).first { throw invalid }
                    guard admits(extended) else {
                        throw Refusal(
                            .introspectionLimit,
                            "Full introspection of the schema with this contribution would exceed the request policy."
                        )
                    }
                    schema = extended
                    admitted.append(candidate)
                } catch let refusal as Refusal {
                    diagnostics.append(refusal.diagnostic(for: candidate.active))
                } catch {
                    diagnostics.append(
                        Refusal(.invalidSDL, sdlMessage(error)).diagnostic(for: candidate.active)
                    )
                }
            }
            return (schema, admitted)
        }
        var composed = compose(candidates, admits: admits)

        // Additional capability requirements are the one dependency between
        // contributions, and it is checked only after every ordinary refusal:
        // an owner that is not admitted removes each contribution naming it, and
        // that removal can leave another without its owner. Removal repeats until
        // the admitted set stops changing. It only removes: a contribution
        // refused above is not reconsidered, and one that merely failed to start
        // is not here at all. A dependency cycle among admitted providers is
        // satisfied, since a name is not a call.
        var removed = false
        while true {
            let present = Set(composed.admitted.map(\.providerId))
            let stranded = composed.admitted.filter { !$0.additionalOwners.isSubset(of: present) }
            guard !stranded.isEmpty else { break }
            removed = true
            for candidate in stranded {
                let missing = candidate.additionalOwners.subtracting(present).sorted()
                diagnostics.append(
                    Refusal(
                        .missingCapabilityOwner,
                        "A field requires a capability of \(missing.joined(separator: ", ")), which is not an admitted provider."
                    ).diagnostic(for: candidate.active)
                )
            }
            composed.admitted.removeAll { candidate in
                stranded.contains { $0.index == candidate.index }
            }
        }
        if removed {
            // The schema is rebuilt from what survives; a subset of a schema
            // that was admitted needs no second admission.
            composed = compose(composed.admitted) { _ in true }
        }
        self.schema = composed.schema
        self.accepted = composed.admitted.map { ProviderContribution(active: $0.active) }
        self.diagnostics = diagnostics
    }
}

private struct Refusal: Error {
    let reason: ProviderDiagnostic.Reason
    let message: String
    var reservedIdentity = false

    init(_ reason: ProviderDiagnostic.Reason, _ message: String) {
        self.reason = reason
        self.message = message
    }

    func diagnostic(for active: ActiveProvider) -> ProviderDiagnostic {
        ProviderDiagnostic(
            providerId: active.descriptor.providerId, reason: reason, message: message
        )
    }
}

private func sdlMessage(_ error: any Error) -> String {
    "Invalid SDL: \((error as? GraphQLError)?.message ?? "the schema could not be built")"
}

/// One provider's contribution, checked on its own against the core.
private struct Candidate {
    let index: Int
    let active: ActiveProvider
    let document: Document
    /// Type names, `Query.`/`Mutation.` root coordinates and `@directive` names.
    let claimedNames: Set<String>
    /// The other providers whose capabilities its fields additionally require.
    let additionalOwners: Set<String>

    var providerId: String { active.descriptor.providerId }

    private static let rootTypes: Set = ["Query", "Mutation"]
    private static let reservedTypeNames: Set = [
        "Query", "Mutation", "Subscription", referenceScalarName,
        "String", "Int", "Float", "Boolean", "ID",
    ]

    init(
        index: Int, active: ActiveProvider, core: GraphQLSchema, policy: RequestPolicy,
        reserved: [ReservedIdentity]
    ) throws {
        self.index = index
        self.active = active
        let descriptor = active.descriptor

        // Identity.
        let prefix = descriptor.graphQLPrefix
        guard isProviderIdentifier(descriptor.providerId), Self.isPrefix(prefix) else {
            throw Refusal(
                .invalidIdentity,
                "A provider identifier is lower-case letters and digits; a prefix is a capitalised GraphQL name."
            )
        }
        for claimed in [descriptor.providerId, prefix]
        where Self.owner(
            of: claimed, provider: descriptor.providerId, shipped: active.origin == .bundled,
            reserved: reserved
        ) != nil {
            var refusal = Refusal(.reservedName, "\(claimed) is reserved.")
            refusal.reservedIdentity = true
            throw refusal
        }
        let missing = Set(descriptor.requiredFeatures).subtracting(koineHostFeatures)
        guard missing.isEmpty else {
            throw Refusal(
                .unsupportedFeature,
                "This host lacks required features: \(missing.sorted().joined(separator: ", "))."
            )
        }
        // Silently ignoring a set the provider did not declare the feature for
        // is never a fallback: the declaration is what an old host refuses on.
        guard
            descriptor.requiredFeatures.contains(ProviderDescriptor.additionalCapabilitiesFeature)
                || descriptor.fields.allSatisfy({ $0.additionalRequirements.isEmpty })
        else {
            throw Refusal(
                .undeclaredFeature,
                "A field requires additional capabilities, and the descriptor does not declare \(ProviderDescriptor.additionalCapabilitiesFeature)."
            )
        }

        // SDL. The parser recurses without a bound of its own, as it does for a
        // request, so the same nesting limit comes first.
        do {
            try RequestLimits(policy: policy).checkSyntaxNesting(of: descriptor.schemaSDL)
            document = try parse(source: descriptor.schemaSDL)
        } catch let exceeded as RequestLimits.Exceeded {
            throw Refusal(.invalidSDL, "Invalid SDL: \(exceeded.message)")
        } catch {
            throw Refusal(.invalidSDL, sdlMessage(error))
        }
        let lowerPrefix = prefix.prefix(1).lowercased() + prefix.dropFirst()
        let shipped = active.origin == .bundled
        func checkName(_ name: String, _ what: String, prefix required: String) throws {
            if Self.reservedTypeNames.contains(name) || name.hasPrefix("__") {
                throw Refusal(.reservedName, "\(what) \(name) is reserved.")
            }
            if let owner = Self.owner(
                of: name, provider: descriptor.providerId, shipped: shipped, reserved: reserved
            ) {
                throw Refusal(.reservedName, "\(what) \(name) uses the \(owner) prefix.")
            }
            guard name.hasPrefix(required) else {
                throw Refusal(.missingPrefix, "\(what) \(name) does not start with \(required).")
            }
        }

        var claimed: Set<String> = []
        var defined: Set<String> = []
        /// Object fields by coordinate, with the named type each returns.
        var fields: [(coordinate: String, returns: String)] = []
        var objectFields: [String: [String]] = [:]
        /// Named types a contribution may use: its own, the built-in scalars and
        /// `Reference`. A field typed as a core object would imitate the core.
        var used: Set<String> = []
        func use(_ inputs: [InputValueDefinition]) throws {
            for input in inputs {
                used.insert(namedType(input.type))
                // The library expands an object default through the input
                // type's own defaults, without a bound.
                if let value = input.defaultValue, containsObject(value) {
                    throw Refusal(
                        .invalidSDL,
                        "\(input.name.value) has an input-object default value, which this version does not accept."
                    )
                }
                // A default the scalar cannot serve would fail introspection for
                // every client, whatever grant it holds.
                if namedType(input.type) == referenceScalarName, let value = input.defaultValue,
                    !isReferenceLiteral(value)
                {
                    throw Refusal(
                        .invalidSDL,
                        "\(input.name.value) has a default that is not a Reference."
                    )
                }
            }
        }
        for definition in document.definitions {
            switch definition {
            case let object as ObjectTypeDefinition:
                for field in object.fields { try use(field.arguments) }
            case let ext as TypeExtensionDefinition:
                for field in ext.definition.fields { try use(field.arguments) }
            case let input as InputObjectTypeDefinition: try use(input.fields)
            case let ext as InputObjectExtensionDefinition: try use(ext.definition.fields)
            case let directive as DirectiveDefinition: try use(directive.arguments)
            default: break
            }
        }
        func add(_ object: ObjectTypeDefinition) throws {
            for field in object.fields {
                // GraphQLSwift 4.2.0 drops null elements when it completes a list
                // (Execution/Execute.swift, completeListValue), so such a field
                // could not hold the values its type declares.
                guard !hasNullableElement(field.type) else {
                    throw Refusal(
                        .invalidSDL,
                        "\(object.name.value).\(field.name.value): list elements must be non-null in this version."
                    )
                }
                used.insert(namedType(field.type))
                fields.append(("\(object.name.value).\(field.name.value)", namedType(field.type)))
                objectFields[object.name.value, default: []].append(namedType(field.type))
            }
        }
        for definition in document.definitions {
            if let type = definition as? TypeDefinition { defined.insert(type.name.value) }
        }
        for definition in document.definitions {
            switch definition {
            case let object as ObjectTypeDefinition:
                try checkName(object.name.value, "Type", prefix: prefix)
                claimed.insert(object.name.value)
                try add(object)
            case is InterfaceTypeDefinition, is UnionTypeDefinition,
                is InterfaceExtensionDefinition, is UnionExtensionDefinition:
                throw Refusal(
                    .invalidSDL, "Interfaces and unions cannot be contributed in this version."
                )
            case let type as TypeDefinition:
                try checkName(type.name.value, "Type", prefix: prefix)
                claimed.insert(type.name.value)
            case let directive as DirectiveDefinition:
                try checkName(directive.name.value, "Directive", prefix: lowerPrefix)
                claimed.insert("@\(directive.name.value)")
            case let ext as TypeExtensionDefinition:
                let name = ext.definition.name.value
                if Self.rootTypes.contains(name) {
                    guard ext.definition.directives.isEmpty, ext.definition.interfaces.isEmpty
                    else {
                        throw Refusal(
                            .foreignTypeExtension,
                            "An extension of \(name) adds fields only; it cannot alter the core's type."
                        )
                    }
                    for field in ext.definition.fields {
                        try checkName(field.name.value, "Root field", prefix: lowerPrefix)
                        claimed.insert("\(name).\(field.name.value)")
                    }
                } else if !defined.contains(name) {
                    throw Refusal(.foreignTypeExtension, "Type \(name) belongs to another owner.")
                }
                try add(ext.definition)
            case let ext as ScalarExtensionDefinition:
                try Self.requireOwn(ext.definition.name.value, in: defined)
            case let ext as EnumExtensionDefinition:
                try Self.requireOwn(ext.definition.name.value, in: defined)
            case let ext as InputObjectExtensionDefinition:
                try Self.requireOwn(ext.definition.name.value, in: defined)
            default:
                throw Refusal(
                    .invalidSDL,
                    "A contribution holds type and directive definitions and extensions of Query and Mutation only."
                )
            }
        }
        claimedNames = claimed
        let usable = defined.union(["String", "Int", "Float", "Boolean", "ID", referenceScalarName])
        if let foreign = used.subtracting(usable).sorted().first {
            throw Refusal(
                .invalidSDL,
                "Invalid SDL: \(foreign) is not this provider's type, a built-in scalar or Reference."
            )
        }

        // Registrations.
        var registered: [String: ProviderFieldRegistration] = [:]
        for registration in descriptor.fields {
            guard registered.updateValue(registration, forKey: registration.coordinate) == nil else {
                throw Refusal(
                    .unknownCoordinate, "\(registration.coordinate) is registered more than once."
                )
            }
        }
        let contributed = Set(fields.map(\.coordinate))
        if let stray = registered.keys.filter({ !contributed.contains($0) }).sorted().first {
            throw Refusal(.unknownCoordinate, "\(stray) is registered but not contributed.")
        }
        // A field a query can reach is a read, whatever type it sits on.
        var queryReachable: Set<String> = ["Query"]
        var frontier = ["Query"]
        while let type = frontier.popLast() {
            for next in objectFields[type] ?? [] where queryReachable.insert(next).inserted {
                frontier.append(next)
            }
        }
        for (coordinate, _) in fields.sorted(by: { $0.coordinate < $1.coordinate }) {
            guard let registration = registered[coordinate], !registration.resolverId.isEmpty else {
                throw Refusal(.missingResolver, "\(coordinate) has no resolver.")
            }
            let type = String(coordinate.prefix { $0 != "." })
            switch registration.authority {
            case .read:
                guard type != "Mutation" else {
                    throw Refusal(
                        .unclassifiedField, "\(coordinate) is an action and must require control."
                    )
                }
            case .control:
                guard !queryReachable.contains(type) else {
                    throw Refusal(
                        .actionOutsideMutation,
                        "\(coordinate) requires control, but a query can reach it; only root Mutation fields act."
                    )
                }
            @unknown default:
                throw Refusal(.unclassifiedField, "\(coordinate) has no known authority requirement.")
            }
            for requirement in registration.additionalRequirements {
                // Core enrollment and management authority are the core's alone:
                // a provider names provider capabilities, never `koine:*`.
                // `koine` is the core's, and every identifier under its prefix is
                // reserved to it, so no provider can hold one: refused here, not
                // admitted and removed later for a missing owner.
                guard isProviderIdentifier(requirement.providerId),
                    !requirement.providerId.hasPrefix("koine")
                else {
                    throw Refusal(
                        .invalidCapabilityRequirement,
                        "\(coordinate) requires a capability of \(requirement.providerId), which no provider can be."
                    )
                }
                switch requirement.kind {
                case .read: break
                case .control:
                    // Only a root Mutation field, or what one alone returns, acts.
                    guard !queryReachable.contains(type) else {
                        throw Refusal(
                            .invalidCapabilityRequirement,
                            "\(coordinate) additionally requires \(requirement.providerId):control, but a query can reach it; a field a query can reach may add reads only."
                        )
                    }
                @unknown default:
                    throw Refusal(
                        .invalidCapabilityRequirement,
                        "\(coordinate) has an additional requirement of an unknown kind."
                    )
                }
            }
        }
        additionalOwners = Set(
            descriptor.fields.flatMap(\.additionalRequirements).map(\.providerId)
        ).subtracting([descriptor.providerId])

        // Against the core alone: a contribution cannot lean on another's types.
        do {
            let alone = try extendSchema(schema: core, documentAST: document)
            if let invalid = validateSchema(schema: alone).first { throw invalid }
        } catch {
            throw Refusal(.invalidSDL, sdlMessage(error))
        }
    }

    private static func requireOwn(_ name: String, in defined: Set<String>) throws {
        guard defined.contains(name) else {
            throw Refusal(.foreignTypeExtension, "Type \(name) belongs to another owner.")
        }
    }

    private static func isPrefix(_ text: String) -> Bool {
        guard let first = text.unicodeScalars.first, ("A"..."Z").contains(first) else { return false }
        return text.unicodeScalars.allSatisfy {
            ("A"..."Z").contains($0) || ("a"..."z").contains($0) || ("0"..."9").contains($0)
        }
    }

    /// The owner whose prefix `name` falls under, when this provider is not it.
    /// The core owns `koine`/`Koine`; each reserved identity belongs to the
    /// shipped provider selected for it, and to no other claimant.
    private static func owner(
        of name: String, provider: String, shipped: Bool, reserved: [ReservedIdentity]
    ) -> String? {
        let lower = name.lowercased()
        if lower.hasPrefix("koine") { return "koine" }
        for identity in reserved
        where lower.hasPrefix(identity.providerId) || lower.hasPrefix(identity.graphQLPrefix.lowercased()) {
            if shipped, identity.providerId == provider { continue }
            return identity.providerId
        }
        return nil
    }
}

/// A `Reference` default: a null, a well-formed reference, or a list of them.
private func isReferenceLiteral(_ value: any Value) -> Bool {
    switch value {
    case is NullValue: true
    case let text as StringValue: ReferenceEnvelope(text.value) != nil
    case let list as ListValue: list.values.allSatisfy(isReferenceLiteral)
    default: false
    }
}

private func containsObject(_ value: any Value) -> Bool {
    switch value {
    case is ObjectValue: true
    case let list as ListValue: list.values.contains(where: containsObject)
    default: false
    }
}

private func hasNullableElement(_ type: Type) -> Bool {
    switch type {
    case let list as ListType: !(list.type is NonNullType) || hasNullableElement(list.type)
    case let nonNull as NonNullType: hasNullableElement(nonNull.type)
    default: false
    }
}

private func namedType(_ type: Type) -> String {
    switch type {
    case let named as NamedType: named.name.value
    case let list as ListType: namedType(list.type)
    case let nonNull as NonNullType: namedType(nonNull.type)
    default: ""
    }
}
