import GraphQL
import KoineProviderAPI

/// A loaded provider: the descriptor it was composed from and the instance the
/// host holds for its active lifetime. How it was loaded is not the core's
/// concern.
public struct ActiveProvider: Sendable {
    public let descriptor: ProviderDescriptor
    public let provider: any Provider

    public init(descriptor: ProviderDescriptor, provider: any Provider) {
        self.descriptor = descriptor
        self.provider = provider
    }
}

/// Turns a provider's descriptor into the engine's own registrations, so its
/// fields take the same authorized path as the core's.
struct ProviderContribution {
    let active: ActiveProvider

    var readCapability: String { "\(active.descriptor.providerId):read" }
    var controlCapability: String { "\(active.descriptor.providerId):control" }

    var registrations: [String: FieldRegistration] {
        var all: [String: FieldRegistration] = [:]
        let provider = active.provider
        for field in active.descriptor.fields {
            let capability: String
            switch field.authority {
            case .read: capability = readCapability
            case .control: capability = controlCapability
            @unknown default: continue  // left unclassified, which refuses the schema
            }
            let resolverId = field.resolverId
            all[field.coordinate] = FieldRegistration(authority: .capability(capability)) { input in
                let request = ResolutionRequest(
                    resolverId: resolverId,
                    arguments: (input.arguments.dictionary ?? [:]).reduce(into: [:]) {
                        $0[$1.key] = providerValue($1.value)
                    },
                    parent: providerValue(input.parent)
                )
                switch await provider.resolve(request) {
                case .success(let value):
                    return native(value)
                case .failure(let failure):
                    switch failure.kind {
                    case .unavailable: throw DomainError.unavailable(failure.message)
                    case .failed: throw DomainError.failed(failure.message)
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

private func providerValue(_ map: Map) -> ProviderValue {
    switch map {
    case .undefined, .null: .null
    case .bool(let value): .bool(value)
    case .number(let value):
        value.storageType == .double ? .double(value.doubleValue) : .int(value.intValue)
    case .string(let value): .string(value)
    case .array(let values): .list(values.map(providerValue))
    case .dictionary(let values):
        .object(values.reduce(into: [:]) { $0[$1.key] = providerValue($1.value) })
    }
}

/// The parent a nested resolver receives is what `native` produced for the
/// enclosing object; a root field's parent is not a provider value.
private func providerValue(_ parent: any Sendable) -> ProviderValue? {
    switch parent {
    case let value as Bool: .bool(value)
    case let value as Int: .int(value)
    case let value as Double: .double(value)
    case let value as String: .string(value)
    case let values as [(any Sendable)?]: .list(values.map { $0.flatMap(providerValue) ?? .null })
    case let values as [String: (any Sendable)?]:
        .object(values.mapValues { $0.flatMap(providerValue) ?? .null })
    default: nil
    }
}

/// The library's resolvers return plain Swift values; objects are dictionaries
/// keyed by field name, as the core's own are.
private func native(_ value: ProviderValue) -> (any Sendable)? {
    switch value {
    case .null: nil
    case .bool(let value): value
    case .int(let value): value
    case .double(let value): value
    case .string(let value): value
    case .list(let values): values.map(native)
    case .object(let values): values.mapValues(native)
    @unknown default: nil
    }
}
