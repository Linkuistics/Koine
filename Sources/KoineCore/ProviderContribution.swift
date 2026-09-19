import GraphQL
import KoineProviderAPI

/// A loaded provider: the descriptor it was composed from and the instance the
/// host holds for its active lifetime. How it was loaded is not the core's
/// concern.
public struct ActiveProvider: Sendable {
    /// Where the provider was installed. Only a bundled provider, sealed inside
    /// the application, may own the `desktop` identifier and prefix.
    public enum Origin: Sendable {
        case bundled
        case external
    }

    public let descriptor: ProviderDescriptor
    public let provider: any Provider
    public let origin: Origin

    public init(descriptor: ProviderDescriptor, provider: any Provider, origin: Origin = .external) {
        self.descriptor = descriptor
        self.provider = provider
        self.origin = origin
    }
}

/// Turns an accepted provider's descriptor into the engine's own registrations,
/// so its fields take the same authorized path as the core's.
struct ProviderContribution {
    let active: ActiveProvider

    var providerId: String { active.descriptor.providerId }
    var readCapability: String { "\(providerId):read" }
    var controlCapability: String { "\(providerId):control" }

    /// `registered` holds every active provider's identifier, for reference
    /// routing. `report` receives a resolver the provider did not recognise.
    func registrations(
        in schema: GraphQLSchema, registered: Set<String>,
        report: @escaping @Sendable (ProviderDiagnostic) -> Void
    ) throws -> [String: FieldRegistration] {
        var all: [String: FieldRegistration] = [:]
        let provider = active.provider
        let providerId = providerId
        for field in active.descriptor.fields {
            let capability: String
            switch field.authority {
            case .read: capability = readCapability
            case .control: capability = controlCapability
            @unknown default: continue  // composition has refused this already
            }
            let parts = field.coordinate.split(separator: ".").map(String.init)
            guard parts.count == 2,
                let definition = try (schema.getType(name: parts[0]) as? GraphQLObjectType)?
                    .fields()[parts[1]]
            else { continue }
            let resolverId = field.resolverId
            let coordinate = field.coordinate
            let argumentTypes = Dictionary(
                uniqueKeysWithValues: definition.args.map { ($0.key, $0.value.type as any GraphQLType) }
            )
            let returnType: any GraphQLType = definition.type
            all[coordinate] = FieldRegistration(authority: .capability(capability)) { input in
                var arguments: [String: ProviderValue] = [:]
                for (name, value) in input.arguments.dictionary ?? [:] {
                    guard let argument = providerValue(value, as: argumentTypes[name]) else {
                        throw DomainError.failed("Argument \(name) is not a value of its type.")
                    }
                    arguments[name] = argument
                }
                // The authority check has passed. The engine reads a reference's
                // provider and nothing else of it.
                for value in arguments.values {
                    try value.forEachReference { reference in
                        guard let envelope = ReferenceEnvelope(reference),
                            registered.contains(envelope.provider)
                        else { throw DomainError.unknownProvider(reference) }
                    }
                }
                let request = ResolutionRequest(
                    requestId: input.requestId, resolverId: resolverId, arguments: arguments,
                    parent: (input.parent as? ProviderObject)?.value
                )
                switch await provider.resolve(request) {
                case .success(let value):
                    guard let result = native(value, as: returnType, depth: 0) else {
                        throw DomainError.failed("The provider returned a malformed value.")
                    }
                    return result.value
                case .failure(let failure):
                    switch failure.kind {
                    case .unavailable: throw DomainError.unavailable(failure.message)
                    case .failed: throw DomainError.failed(failure.message)
                    case .osPermission:
                        throw DomainError.osPermissionMissing(
                            failure.permission ?? "", message: failure.message
                        )
                    case .unknownResolver:
                        report(
                            ProviderDiagnostic(
                                providerId: providerId, reason: .resolverMismatch,
                                message: "The provider has no resolver \(resolverId), registered for \(coordinate)."
                            )
                        )
                        throw DomainError.failed("The provider could not resolve this field.")
                    @unknown default: throw DomainError.failed(failure.message)
                    }
                @unknown default:
                    throw DomainError.failed("The provider returned an unknown result.")
                }
            }
        }
        return all
    }
}

/// What the library carries as the source value of a provider's object, so a
/// nested resolver receives exactly the value its provider returned.
private struct ProviderObject: Sendable {
    let value: ProviderValue
}

private struct Converted {
    let value: (any Sendable)?
    init(_ value: (any Sendable)?) { self.value = value }
}

/// Deepest value tree accepted from a provider for one field.
private let maximumValueDepth = 32

extension ProviderValue {
    fileprivate func forEachReference(_ body: (String) throws -> Void) rethrows {
        switch self {
        case .reference(let reference): try body(reference)
        case .list(let values): for value in values { try value.forEachReference(body) }
        case .object(let values): for value in values.values { try value.forEachReference(body) }
        default: break
        }
    }
}

/// A coerced argument as the provider sees it, by its declared type: the type
/// says which strings are references, and which numbers are integers. The
/// library decodes every JSON number as a double and does not check that an
/// `Int` variable is integral, so that is checked here; nil when it is not.
private func providerValue(_ map: Map, as type: (any GraphQLType)?) -> ProviderValue? {
    let type = (type as? GraphQLNonNull)?.ofType ?? type
    let scalar = (type as? GraphQLScalarType)?.name
    switch map {
    case .undefined, .null: return .null
    case .bool(let value): return .bool(value)
    case .number(let value):
        if scalar == "Float" { return .double(value.doubleValue) }
        if let exact = Int(exactly: value.doubleValue) { return .int(exact) }
        return scalar == "Int" ? nil : .double(value.doubleValue)
    case .string(let value):
        return scalar == referenceScalarName ? .reference(value) : .string(value)
    case .array(let values):
        let element = (type as? GraphQLList)?.ofType
        var elements: [ProviderValue] = []
        for value in values {
            guard let converted = providerValue(value, as: element) else { return nil }
            elements.append(converted)
        }
        return .list(elements)
    case .dictionary(let values):
        let fields = (try? (type as? GraphQLInputObjectType)?.fields()) ?? [:]
        var object: [String: ProviderValue] = [:]
        for (key, value) in values {
            guard let converted = providerValue(value, as: fields[key]?.type) else { return nil }
            object[key] = converted
        }
        return .object(object)
    }
}

/// The library's resolvers return plain Swift values. Nil when the value does
/// not fit `type`: provider output is checked here, where it can be classified,
/// not left to fail in the library's completion.
private func native(
    _ value: ProviderValue, as type: any GraphQLType, depth: Int
) -> Converted? {
    guard depth <= maximumValueDepth else { return nil }
    if let nonNull = type as? GraphQLNonNull {
        guard value != .null else { return nil }
        return native(value, as: nonNull.ofType, depth: depth)
    }
    if value == .null { return Converted(nil) }
    switch type {
    case let list as GraphQLList:
        guard case .list(let values) = value else { return nil }
        var elements: [(any Sendable)?] = []
        for element in values {
            guard let converted = native(element, as: list.ofType, depth: depth + 1) else {
                return nil
            }
            // Composition admits only lists of non-null elements.
            guard let element = converted.value else { return nil }
            elements.append(element)
        }
        return Converted(elements)
    case is GraphQLObjectType:
        guard case .object = value, value.depth(limit: maximumValueDepth - depth) != nil else {
            return nil
        }
        return Converted(ProviderObject(value: value))
    case let enumeration as GraphQLEnumType:
        guard case .string(let name) = value, enumeration.values.contains(where: { $0.name == name })
        else { return nil }
        return Converted(name)
    case let scalar as GraphQLScalarType:
        switch (scalar.name, value) {
        case (referenceScalarName, .reference(let reference)):
            return ReferenceEnvelope(reference) == nil ? nil : Converted(reference)
        case (referenceScalarName, _): return nil
        case ("String", .string(let text)), ("ID", .string(let text)): return Converted(text)
        case ("Int", .int(let number)):
            return Int32(exactly: number) == nil ? nil : Converted(number)
        case ("ID", .int(let number)): return Converted(String(number))
        case ("Float", .int(let number)): return Converted(Double(number))
        case ("Float", .double(let number)): return number.isFinite ? Converted(number) : nil
        case ("Boolean", .bool(let flag)): return Converted(flag)
        case ("String", _), ("ID", _), ("Int", _), ("Float", _), ("Boolean", _): return nil
        // A provider-private scalar carries any scalar value.
        case (_, .bool(let flag)): return Converted(flag)
        case (_, .int(let number)): return Converted(number)
        case (_, .double(let number)): return number.isFinite ? Converted(number) : nil
        case (_, .string(let text)): return Converted(text)
        default: return nil
        }
    default:
        return nil
    }
}

extension ProviderValue {
    /// The tree's depth, or nil when it is deeper than `limit`.
    fileprivate func depth(limit: Int) -> Int? {
        guard limit >= 0 else { return nil }
        let children: [ProviderValue]
        switch self {
        case .list(let values): children = values
        case .object(let values): children = Array(values.values)
        default: return 0
        }
        var deepest = 0
        for child in children {
            guard let depth = child.depth(limit: limit - 1) else { return nil }
            deepest = max(deepest, depth + 1)
        }
        return deepest
    }
}
