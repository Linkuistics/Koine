import Foundation
import GraphQL

/// The size of the response to full standard introspection of a schema, for
/// schema admission (docs/specs/machine.md, "Public GraphQL contract"). The
/// depth and selection count of the standard introspection query do not depend
/// on the schema; its response size does.
///
/// Composition is synchronous and the library executes asynchronously, so the
/// response is modelled here: the graphql-js `getIntrospectionQuery()` selection
/// with every optional field it can carry (`specifiedByURL`, `isOneOf`,
/// `isRepeatable`, input-value deprecation), which makes this an upper bound on
/// the query a code generator sends.
enum IntrospectionSize {
    /// The library keeps a schema's description to itself, so the caller, which
    /// wrote it, supplies it.
    static func bytes(of schema: GraphQLSchema, schemaDescription: String?) -> Int {
        let types = schema.typeMap.values.map(fullType)
        let directives = schema.directives.map { directive -> [String: Any] in
            [
                "name": directive.name,
                "description": directive.description as Any? ?? NSNull(),
                "isRepeatable": directive.isRepeatable,
                "locations": directive.locations.map(\.rawValue),
                "args": directive.args.map(inputValue),
            ]
        }
        let root: [String: Any] = [
            "data": [
                "__schema": [
                    "description": schemaDescription as Any? ?? NSNull(),
                    "queryType": name(schema.queryType),
                    "mutationType": name(schema.mutationType),
                    "subscriptionType": name(schema.subscriptionType),
                    "types": types,
                    "directives": directives,
                ]
            ]
        ]
        return (try? JSONSerialization.data(withJSONObject: root).count) ?? .max
    }

    private static func name(_ type: GraphQLObjectType?) -> Any {
        type.map { ["name": $0.name] as [String: Any] } ?? NSNull()
    }

    private static func fullType(_ type: any GraphQLNamedType) -> [String: Any] {
        var result: [String: Any] = [
            "kind": kind(of: type), "name": type.name,
            "description": description(of: type) ?? NSNull(),
            "specifiedByURL": (type as? GraphQLScalarType)?.specifiedByURL as Any? ?? NSNull(),
            "isOneOf": (type as? GraphQLInputObjectType)?.isOneOf ?? false,
            "fields": NSNull(), "inputFields": NSNull(), "interfaces": NSNull(),
            "enumValues": NSNull(), "possibleTypes": NSNull(),
        ]
        switch type {
        case let object as GraphQLObjectType:
            result["fields"] = ((try? object.fields()) ?? [:]).map(field)
            result["interfaces"] = ((try? object.interfaces()) ?? []).map { typeRef($0) }
        case let interface as GraphQLInterfaceType:
            result["fields"] = ((try? interface.fields()) ?? [:]).map(field)
            result["interfaces"] = ((try? interface.interfaces()) ?? []).map { typeRef($0) }
        case let union as GraphQLUnionType:
            result["possibleTypes"] = ((try? union.types()) ?? []).map { typeRef($0) }
        case let enumeration as GraphQLEnumType:
            result["enumValues"] = enumeration.values.map { value -> [String: Any] in
                [
                    "name": value.name, "description": value.description as Any? ?? NSNull(),
                    "isDeprecated": value.deprecationReason != nil,
                    "deprecationReason": value.deprecationReason as Any? ?? NSNull(),
                ]
            }
        case let input as GraphQLInputObjectType:
            result["inputFields"] = ((try? input.fields()) ?? [:]).map { name, field in
                inputValue(
                    name: name, description: field.description, type: field.type,
                    defaultValue: field.astNode?.defaultValue,
                    deprecationReason: field.deprecationReason
                )
            }
        default:
            break
        }
        return result
    }

    private static func field(name: String, _ field: GraphQLField) -> [String: Any] {
        [
            "name": name, "description": field.description as Any? ?? NSNull(),
            "args": field.args.map { name, argument in
                inputValue(
                    name: name, description: argument.description, type: argument.type,
                    defaultValue: argument.astNode?.defaultValue,
                    deprecationReason: argument.deprecationReason
                )
            },
            "type": typeRef(field.type),
            "isDeprecated": field.deprecationReason != nil,
            "deprecationReason": field.deprecationReason as Any? ?? NSNull(),
        ]
    }

    private static func inputValue(_ argument: GraphQLArgumentDefinition) -> [String: Any] {
        inputValue(
            name: argument.name, description: argument.description, type: argument.type,
            defaultValue: argument.astNode?.defaultValue,
            deprecationReason: argument.deprecationReason
        )
    }

    /// Every served schema is built from SDL, so a default value is its AST. The
    /// library serves the coerced default, which can be longer than it was
    /// written: a lone value becomes a list at each list level and an integer
    /// becomes a float. Composition refuses input-object defaults, the one
    /// coercion that grows without such a bound.
    private static func inputValue(
        name: String, description: String?, type: any GraphQLType, defaultValue: (any Value)?,
        deprecationReason: String?
    ) -> [String: Any] {
        [
            "name": name, "description": description as Any? ?? NSNull(), "type": typeRef(type),
            "defaultValue": defaultValue.map {
                print(ast: $0) + String(repeating: " ", count: coercionAllowance(print(ast: $0), type))
            } as Any? ?? NSNull(),
            "isDeprecated": deprecationReason != nil,
            "deprecationReason": deprecationReason as Any? ?? NSNull(),
        ]
    }

    /// Two brackets for each list level, and ".0" for each number written.
    private static func coercionAllowance(_ printed: String, _ type: any GraphQLType) -> Int {
        var levels = 0
        var type = type
        while true {
            if let list = type as? GraphQLList { levels += 1; type = list.ofType }
            else if let nonNull = type as? GraphQLNonNull { type = nonNull.ofType }
            else { break }
        }
        return 2 * levels + 2 * (printed.split(separator: ",").count)
    }

    private static func typeRef(_ type: any GraphQLType) -> [String: Any] {
        switch type {
        case let list as GraphQLList:
            ["kind": "LIST", "name": NSNull(), "ofType": typeRef(list.ofType)]
        case let nonNull as GraphQLNonNull:
            ["kind": "NON_NULL", "name": NSNull(), "ofType": typeRef(nonNull.ofType)]
        case let named as any GraphQLNamedType:
            ["kind": kind(of: named), "name": named.name, "ofType": NSNull()]
        default:
            [:]
        }
    }

    private static func kind(of type: any GraphQLNamedType) -> String {
        switch type {
        case is GraphQLScalarType: "SCALAR"
        case is GraphQLObjectType: "OBJECT"
        case is GraphQLInterfaceType: "INTERFACE"
        case is GraphQLUnionType: "UNION"
        case is GraphQLEnumType: "ENUM"
        default: "INPUT_OBJECT"
        }
    }

    private static func description(of type: any GraphQLNamedType) -> String? {
        switch type {
        case let type as GraphQLScalarType: type.description
        case let type as GraphQLObjectType: type.description
        case let type as GraphQLInterfaceType: type.description
        case let type as GraphQLUnionType: type.description
        case let type as GraphQLEnumType: type.description
        case let type as GraphQLInputObjectType: type.description
        default: nil
        }
    }
}
