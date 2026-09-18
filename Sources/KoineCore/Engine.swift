import Crypto
import Foundation
import GraphQL

public let koineContractVersion = "koine-desktop/1"

/// One GraphQL request, decoded from the JSON body a transport received.
public struct EngineRequest: Sendable {
    let query: String
    let variables: [String: Map]
    let operationName: String?

    /// Decodes `{"query", "variables", "operationName"}`. Throws when the body
    /// is not that JSON shape.
    public init(jsonBody: Data) throws {
        let decoded = try JSONDecoder().decode(GraphQLRequest.self, from: jsonBody)
        query = decoded.query
        variables = decoded.variables
        operationName = decoded.operationName
    }
}

/// The JSON response body and how the operation ended, for status mapping.
public struct EngineResponse: Sendable {
    public enum Outcome: Sendable {
        /// Executed. The body, not this case, says whether fields succeeded.
        case executed
        /// Syntax, validation or operation-selection failure; nothing executed.
        case invalidRequest
        /// The principal is not admitted; nothing executed.
        case unauthenticated
        /// Mutation preflight denied the whole operation; no action began.
        case forbidden
    }

    public let outcome: Outcome
    public let body: Data
}

/// The Machine core's GraphQL execution. Transports and the in-process console
/// both execute through `execute(_:as:)`; there is no second path.
public final class Engine: Sendable {
    public let instanceId: String
    public let schemaDigest: String

    private let schema: GraphQLSchema
    private let authority: Authority
    private let fieldAuthorities: [String: FieldAuthority]

    public init(store: any GrantStore, instanceId: String) throws {
        self.instanceId = instanceId
        authority = Authority(store: store)

        let schema = try buildSchema(source: coreSchemaSDL)
        // Defined in docs/specs/machine.md, "Schema digest".
        schemaDigest = Engine.digest(of: schema)

        let fields = CoreFields(
            store: store, instanceId: instanceId, schemaDigest: schemaDigest
        ).registrations
        try Engine.install(fields, on: schema, authority: authority)
        self.schema = schema
        fieldAuthorities = fields.mapValues(\.authority)
    }

    /// The principal for a presented bearer credential, or nil. A store failure
    /// also yields nil: authentication fails closed.
    public func authenticate(bearer: String) -> Principal? {
        (try? authority.authenticate(bearer: bearer)) ?? nil
    }

    public func execute(_ request: EngineRequest, as principal: Principal) async -> EngineResponse {
        guard (try? authority.capabilities(of: principal)) ?? nil != nil else {
            return respond(.unauthenticated, errors: [GraphQLError(message: "Not authenticated.")])
        }

        let document: Document
        do { document = try parse(source: request.query) } catch {
            return respond(.invalidRequest, errors: [error as? GraphQLError ?? GraphQLError(error)])
        }
        let validationErrors = validate(schema: schema, ast: document)
        guard validationErrors.isEmpty else {
            return respond(.invalidRequest, errors: validationErrors)
        }

        let denied = preflightDenials(in: document, request: request, principal: principal)
        guard denied.isEmpty else { return respond(.forbidden, errors: denied) }

        do {
            let result = try await GraphQL.execute(
                schema: schema,
                documentAST: document,
                rootValue: (),
                context: principal,
                variableValues: request.variables,
                operationName: request.operationName
            )
            return EngineResponse(outcome: .executed, body: try encode(result))
        } catch {
            return respond(.executed, errors: [error as? GraphQLError ?? GraphQLError(error)])
        }
    }

    // MARK: Mutation preflight

    /// Checks every selected root mutation action against the principal's
    /// current authority before any action begins. No resolver runs here.
    private func preflightDenials(
        in document: Document, request: EngineRequest, principal: Principal
    ) -> [GraphQLError] {
        let operations = document.definitions.compactMap { $0 as? OperationDefinition }
        guard
            let operation = operations.first(where: {
                request.operationName == nil || $0.name?.value == request.operationName
            }),
            operation.operation == .mutation
        else { return [] }

        var fragments: [String: FragmentDefinition] = [:]
        for case let fragment as FragmentDefinition in document.definitions {
            fragments[fragment.name.value] = fragment
        }
        var variables: [String: Bool] = [:]
        for definition in operation.variableDefinitions {
            let name = definition.variable.name.value
            variables[name] = request.variables[name]?.bool
                ?? (definition.defaultValue as? BooleanValue)?.value
        }

        var actions: [Field] = []
        var visited: Set<String> = []
        collectRootFields(
            operation.selectionSet, fragments: fragments, variables: variables,
            visited: &visited, into: &actions
        )

        return actions.compactMap { action in
            guard let requirement = fieldAuthorities["Mutation.\(action.name.value)"] else {
                return nil  // introspection meta-fields such as __typename
            }
            do {
                try authority.check(requirement, for: principal)
                return nil
            } catch {
                let alias = action.alias?.value ?? action.name.value
                return Engine.graphQLError(
                    error, nodes: [action], path: [alias], phase: "authorization"
                )
            }
        }
    }

    private func collectRootFields(
        _ selectionSet: SelectionSet, fragments: [String: FragmentDefinition],
        variables: [String: Bool], visited: inout Set<String>, into actions: inout [Field]
    ) {
        for selection in selectionSet.selections {
            switch selection {
            case let field as Field where isIncluded(field.directives, variables):
                actions.append(field)
            case let inline as InlineFragment where isIncluded(inline.directives, variables):
                collectRootFields(
                    inline.selectionSet, fragments: fragments, variables: variables,
                    visited: &visited, into: &actions
                )
            case let spread as FragmentSpread where isIncluded(spread.directives, variables):
                let name = spread.name.value
                guard visited.insert(name).inserted, let fragment = fragments[name] else { continue }
                collectRootFields(
                    fragment.selectionSet, fragments: fragments, variables: variables,
                    visited: &visited, into: &actions
                )
            default:
                continue
            }
        }
    }

    /// `@skip` / `@include`. A condition that cannot be decided here counts as
    /// included, so an undecidable denied action still denies the operation;
    /// execution then rejects the bad variable before any action.
    private func isIncluded(_ directives: [Directive], _ variables: [String: Bool]) -> Bool {
        for directive in directives {
            let name = directive.name.value
            guard name == "skip" || name == "include",
                let argument = directive.arguments.first(where: { $0.name.value == "if" })
            else { continue }
            let condition: Bool?
            switch argument.value {
            case let literal as BooleanValue: condition = literal.value
            case let variable as Variable: condition = variables[variable.name.value]
            default: condition = nil
            }
            guard let condition else { continue }
            if name == "skip", condition { return false }
            if name == "include", !condition { return false }
        }
        return true
    }

    // MARK: Schema digest

    /// Order-independent by construction: definitions are sorted by name, so the
    /// digest does not depend on the order contributions were composed in.
    private static func digest(of schema: GraphQLSchema) -> String {
        let builtInScalars: Set = ["String", "Int", "Float", "Boolean", "ID"]
        let builtInDirectives: Set = ["skip", "include", "deprecated", "specifiedBy", "oneOf"]
        let directives = schema.directives
            .filter { !builtInDirectives.contains($0.name) }
            .sorted { $0.name < $1.name }
            .map { printDirective(directive: $0) }
        let types = schema.typeMap.values
            .filter { !$0.name.hasPrefix("__") && !builtInScalars.contains($0.name) }
            .sorted { $0.name < $1.name }
            .map { printType(type: $0) }
        let canonical = (directives + types).joined(separator: "\n\n")
        return hex(SHA256.hash(data: Data(canonical.utf8)))
    }

    // MARK: Schema installation

    /// Gives every object field a host-controlled resolver that checks authority
    /// before the registered resolver runs. A field without a registration is an
    /// error: nothing is served unclassified.
    private static func install(
        _ registrations: [String: FieldRegistration], on schema: GraphQLSchema,
        authority: Authority
    ) throws {
        var unused = Set(registrations.keys)
        for (typeName, type) in schema.typeMap where !typeName.hasPrefix("__") {
            guard let object = type as? GraphQLObjectType else { continue }
            let fields = try object.fields()
            for (fieldName, field) in fields {
                let coordinate = "\(typeName).\(fieldName)"
                guard let registration = registrations[coordinate] else {
                    throw SchemaError.unclassifiedField(coordinate)
                }
                unused.remove(coordinate)
                field.resolve = { source, arguments, context, info in
                    do {
                        guard let principal = context as? Principal else {
                            throw DomainError.failed("No principal.")
                        }
                        try authority.check(registration.authority, for: principal)
                        return try await registration.resolve(
                            ResolverInput(parent: source, arguments: arguments, principal: principal)
                        )
                    } catch {
                        throw graphQLError(
                            error, nodes: info.fieldASTs, path: info.path, phase: "execution"
                        )
                    }
                }
            }
            // Reassigning clears the type's cached field definitions.
            object.fields = { fields }
        }
        guard unused.isEmpty else { throw SchemaError.unknownCoordinates(unused.sorted()) }
    }

    /// The library returns a thrown GraphQLError unchanged, so the response path
    /// and the contract's extensions are attached here.
    private static func graphQLError(
        _ error: any Error, nodes: [Field], path: GraphQL.IndexPath, phase: String
    ) -> GraphQLError {
        let domain = error as? DomainError
            ?? DomainError.failed("The operation failed.")  // never leak native detail
        var extensions: [String: Map] = ["kind": .string(domain.kind.rawValue)]
        if domain.kind == .permission {
            extensions["permissionClass"] = "capability"
            extensions["phase"] = .string(phase)
            if let capability = domain.requiredCapability {
                extensions["requiredCapability"] = .string(capability)
            }
        }
        return GraphQLError(
            message: domain.message, nodes: nodes, path: path, extensions: extensions
        )
    }

    private func respond(_ outcome: EngineResponse.Outcome, errors: [GraphQLError]) -> EngineResponse
    {
        let body = (try? encode(GraphQLResult(errors: errors)))
            ?? Data(#"{"errors":[{"message":"Internal error."}]}"#.utf8)
        return EngineResponse(outcome: outcome, body: body)
    }

    private func encode(_ result: GraphQLResult) throws -> Data {
        try GraphQLJSONEncoder().encode(result)
    }
}

public enum SchemaError: Error {
    case unclassifiedField(String)
    case unknownCoordinates([String])
}

struct ResolverInput: Sendable {
    let parent: any Sendable
    let arguments: Map
    let principal: Principal
}

struct FieldRegistration: Sendable {
    let authority: FieldAuthority
    let resolve: @Sendable (ResolverInput) async throws -> (any Sendable)?
}
