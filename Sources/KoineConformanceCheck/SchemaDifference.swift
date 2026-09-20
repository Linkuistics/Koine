import GraphQL

/// One difference between the served schema and the design contract, named by
/// the GraphQL coordinate it sits at and by the aspect that differs.
public struct SchemaDifference: Sendable {
    public enum Aspect: String, Sendable {
        case presence
        case kind
        case declaredOrder = "declared order"
        case type
        case defaultValue = "default"
        case deprecation
        case description
        case members
        case interfaces
        case directives = "applied directives"
    }

    public let coordinate: String
    public let aspect: Aspect
    public let served: String
    public let design: String

    public var report: String {
        """
        \(coordinate) — \(aspect.rawValue)
            served: \(served)
            design: \(design)
        """
    }
}

/// Compares the two schemas as the digest sees them.
///
/// Both sides arrive here as the **canonical text** of `docs/specs/machine.md`'s
/// "Schema digest", parsed back into an AST. That matters: the served schema and
/// the design file reach the comparison through byte-for-byte the same pipeline
/// (SDL text → schema → canonical print → parse), so nothing reported here can
/// come from the two sides having been read differently, and "no differences"
/// and "the digests are equal" are one claim rather than two that could
/// disagree.
///
/// **Declared order of object and input fields is not compared here**, and not
/// because it does not matter: the canonical text keeps it, so it changes the
/// digest. It is not compared because the *introspected* side does not carry it
/// — GraphQLSwift/GraphQL 4.2.0 returns `__Type.fields` and `__Type.inputFields`
/// sorted by name — so a comparison would report a difference for every type
/// whose fields are not already alphabetical, whatever the schemas hold. Field
/// order is checked instead by the digest of the design text against the digest
/// Koine served, which is where it is visible. Argument order and enum-value
/// order *are* preserved by introspection, and are compared.
public struct SchemaComparison {
    public let served: Document
    public let design: Document

    public init(served: Document, design: Document) {
        self.served = served
        self.design = design
    }

    public func differences() -> [SchemaDifference] {
        let servedTypes = definitions(of: served)
        let designTypes = definitions(of: design)
        var found: [SchemaDifference] = []
        for name in union(servedTypes.keys, designTypes.keys) {
            switch (servedTypes[name], designTypes[name]) {
            case let (servedType?, designType?):
                found += compare(servedType, designType, at: name)
            case let (servedType?, nil):
                found.append(
                    .init(
                        coordinate: name, aspect: .presence, served: servedType.kindName,
                        design: "absent"))
            case let (nil, designType?):
                found.append(
                    .init(
                        coordinate: name, aspect: .presence, served: "absent",
                        design: designType.kindName))
            case (nil, nil): break
            }
        }
        return found
    }

    // MARK: The definitions the canonical text carries

    /// What the canonical text can hold: every named type and every custom
    /// directive definition. The schema definition is not in it, by the digest
    /// rule, so it is not compared here.
    private enum Definition {
        case scalar(ScalarTypeDefinition)
        case object(ObjectTypeDefinition)
        case interface(InterfaceTypeDefinition)
        case union(UnionTypeDefinition)
        case enumeration(EnumTypeDefinition)
        case input(InputObjectTypeDefinition)
        case directive(DirectiveDefinition)

        var kindName: String {
            switch self {
            case .scalar: "scalar"
            case .object: "type"
            case .interface: "interface"
            case .union: "union"
            case .enumeration: "enum"
            case .input: "input"
            case .directive: "directive"
            }
        }

        var description: StringValue? {
            switch self {
            case let .scalar(node): node.description
            case let .object(node): node.description
            case let .interface(node): node.description
            case let .union(node): node.description
            case let .enumeration(node): node.description
            case let .input(node): node.description
            case let .directive(node): node.description
            }
        }
    }

    private func definitions(of document: Document) -> [String: Definition] {
        var found: [String: Definition] = [:]
        for definition in document.definitions {
            switch definition {
            case let node as ScalarTypeDefinition: found[node.name.value] = .scalar(node)
            case let node as ObjectTypeDefinition: found[node.name.value] = .object(node)
            case let node as InterfaceTypeDefinition: found[node.name.value] = .interface(node)
            case let node as UnionTypeDefinition: found[node.name.value] = .union(node)
            case let node as EnumTypeDefinition: found[node.name.value] = .enumeration(node)
            case let node as InputObjectTypeDefinition: found[node.name.value] = .input(node)
            case let node as DirectiveDefinition: found["@" + node.name.value] = .directive(node)
            default: break
            }
        }
        return found
    }

    // MARK: Per definition

    private func compare(_ servedType: Definition, _ designType: Definition, at name: String)
        -> [SchemaDifference]
    {
        guard servedType.kindName == designType.kindName else {
            return [
                .init(
                    coordinate: name, aspect: .kind, served: servedType.kindName,
                    design: designType.kindName)
            ]
        }
        var found = describe(name, servedType.description, designType.description)
        switch (servedType, designType) {
        case let (.scalar(servedNode), .scalar(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
        case let (.object(servedNode), .object(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
            found += compareInterfaces(name, servedNode.interfaces, designNode.interfaces)
            found += compareFields(name, servedNode.fields, designNode.fields)
        case let (.interface(servedNode), .interface(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
            found += compareInterfaces(name, servedNode.interfaces, designNode.interfaces)
            found += compareFields(name, servedNode.fields, designNode.fields)
        case let (.union(servedNode), .union(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
            let servedMembers = servedNode.types.map(\.name.value)
            let designMembers = designNode.types.map(\.name.value)
            if servedMembers != designMembers {
                found.append(
                    .init(
                        coordinate: name, aspect: .members,
                        served: servedMembers.joined(separator: " | "),
                        design: designMembers.joined(separator: " | ")))
            }
        case let (.enumeration(servedNode), .enumeration(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
            found += compareEnumValues(name, servedNode.values, designNode.values)
        case let (.input(servedNode), .input(designNode)):
            found += applied(name, servedNode.directives, designNode.directives)
            found += compareInputValues(
                name, "input fields", servedNode.fields, designNode.fields, separator: ".")
        case let (.directive(servedNode), .directive(designNode)):
            let servedLocations = servedNode.locations.map(\.value)
            let designLocations = designNode.locations.map(\.value)
            if servedLocations != designLocations {
                found.append(
                    .init(
                        coordinate: name, aspect: .members,
                        served: servedLocations.joined(separator: " | "),
                        design: designLocations.joined(separator: " | ")))
            }
            found += compareInputValues(
                name, "arguments", servedNode.arguments, designNode.arguments, separator: "")
        default: break
        }
        return found
    }

    private func compareInterfaces(
        _ owner: String, _ servedList: [NamedType], _ designList: [NamedType]
    ) -> [SchemaDifference] {
        let servedNames = servedList.map(\.name.value)
        let designNames = designList.map(\.name.value)
        guard servedNames != designNames else { return [] }
        return [
            .init(
                coordinate: owner, aspect: .interfaces,
                served: servedNames.joined(separator: " & "),
                design: designNames.joined(separator: " & "))
        ]
    }

    private func compareFields(
        _ owner: String, _ servedFields: [FieldDefinition], _ designFields: [FieldDefinition]
    ) -> [SchemaDifference] {
        // No order() call: see the note on this type. Field order reaches the
        // check through the digest, not through the introspected text.
        var found: [SchemaDifference] = []
        let servedByName = byName(servedFields, \.name.value)
        let designByName = byName(designFields, \.name.value)
        for name in union(servedByName.keys, designByName.keys) {
            let coordinate = "\(owner).\(name)"
            switch (servedByName[name], designByName[name]) {
            case let (servedField?, designField?):
                found += compareTypes(coordinate, servedField.type, designField.type)
                found += describe(coordinate, servedField.description, designField.description)
                found += applied(coordinate, servedField.directives, designField.directives)
                found += compareInputValues(
                    coordinate, "arguments", servedField.arguments, designField.arguments,
                    separator: "")
            case let (servedField?, nil):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence,
                        served: text(servedField.type), design: "absent"))
            case let (nil, designField?):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence, served: "absent",
                        design: text(designField.type)))
            case (nil, nil): break
            }
        }
        return found
    }

    /// Arguments and input-object fields are the same node in the grammar, so
    /// they are compared by the same code; `separator` also spells the
    /// coordinate (`Type.field(argument:)` against `Input.field`).
    /// `separator` is empty for arguments, which introspection reports in
    /// declared order and which are therefore compared for order, and "." for an
    /// input object's fields, which it sorts by name and which are not.
    private func compareInputValues(
        _ owner: String, _ what: String, _ servedValues: [InputValueDefinition],
        _ designValues: [InputValueDefinition], separator: String
    ) -> [SchemaDifference] {
        var found =
            separator.isEmpty
            ? order(owner, what, servedValues.map(\.name.value), designValues.map(\.name.value))
            : []
        let servedByName = byName(servedValues, \.name.value)
        let designByName = byName(designValues, \.name.value)
        for name in union(servedByName.keys, designByName.keys) {
            let coordinate =
                separator.isEmpty ? "\(owner)(\(name):)" : "\(owner)\(separator)\(name)"
            switch (servedByName[name], designByName[name]) {
            case let (servedValue?, designValue?):
                found += compareTypes(coordinate, servedValue.type, designValue.type)
                found += compareDefaults(
                    coordinate, servedValue.defaultValue, designValue.defaultValue)
                found += describe(coordinate, servedValue.description, designValue.description)
                found += applied(coordinate, servedValue.directives, designValue.directives)
            case let (servedValue?, nil):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence, served: text(servedValue.type),
                        design: "absent"))
            case let (nil, designValue?):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence, served: "absent",
                        design: text(designValue.type)))
            case (nil, nil): break
            }
        }
        return found
    }

    private func compareEnumValues(
        _ owner: String, _ servedValues: [EnumValueDefinition],
        _ designValues: [EnumValueDefinition]
    ) -> [SchemaDifference] {
        var found = order(
            owner, "enum values", servedValues.map(\.name.value), designValues.map(\.name.value))
        let servedByName = byName(servedValues, \.name.value)
        let designByName = byName(designValues, \.name.value)
        for name in union(servedByName.keys, designByName.keys) {
            let coordinate = "\(owner).\(name)"
            switch (servedByName[name], designByName[name]) {
            case let (servedValue?, designValue?):
                found += describe(coordinate, servedValue.description, designValue.description)
                found += applied(coordinate, servedValue.directives, designValue.directives)
            case (_?, nil):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence, served: "present",
                        design: "absent"))
            case (nil, _?):
                found.append(
                    .init(
                        coordinate: coordinate, aspect: .presence, served: "absent",
                        design: "present"))
            case (nil, nil): break
            }
        }
        return found
    }

    // MARK: Aspects

    private func compareTypes(_ coordinate: String, _ servedType: Type, _ designType: Type)
        -> [SchemaDifference]
    {
        // Nullability is part of a type reference's text, so `String` against
        // `String!` is reported here and needs no aspect of its own.
        let servedText = text(servedType)
        let designText = text(designType)
        return servedText == designText
            ? []
            : [.init(coordinate: coordinate, aspect: .type, served: servedText, design: designText)]
    }

    private func compareDefaults(_ coordinate: String, _ servedValue: Value?, _ designValue: Value?)
        -> [SchemaDifference]
    {
        let servedText = servedValue.map { print(ast: $0) } ?? "none"
        let designText = designValue.map { print(ast: $0) } ?? "none"
        return servedText == designText
            ? []
            : [
                .init(
                    coordinate: coordinate, aspect: .defaultValue, served: servedText,
                    design: designText)
            ]
    }

    private func describe(
        _ coordinate: String, _ servedText: StringValue?, _ designText: StringValue?
    ) -> [SchemaDifference] {
        let servedValue = servedText?.value
        let designValue = designText?.value
        return servedValue == designValue
            ? []
            : [
                .init(
                    coordinate: coordinate, aspect: .description, served: quoted(servedValue),
                    design: quoted(designValue))
            ]
    }

    /// Applied directives, which in the canonical text means `@deprecated` and
    /// `@specifiedBy`: both are printed onto the definition they apply to.
    private func applied(
        _ coordinate: String, _ servedList: [Directive], _ designList: [Directive]
    ) -> [SchemaDifference] {
        let servedText = servedList.map { print(ast: $0) }.sorted()
        let designText = designList.map { print(ast: $0) }.sorted()
        guard servedText != designText else { return [] }
        let deprecationOnly = (servedText + designText).allSatisfy {
            $0.hasPrefix("@deprecated")
        }
        return [
            .init(
                coordinate: coordinate, aspect: deprecationOnly ? .deprecation : .directives,
                served: servedText.isEmpty ? "none" : servedText.joined(separator: " "),
                design: designText.isEmpty ? "none" : designText.joined(separator: " "))
        ]
    }

    private func order(
        _ owner: String, _ what: String, _ servedNames: [String], _ designNames: [String]
    ) -> [SchemaDifference] {
        // Only when the two sides hold the same set: a presence difference is
        // reported on its own, and would otherwise be reported twice.
        guard Set(servedNames) == Set(designNames), servedNames != designNames else { return [] }
        return [
            .init(
                coordinate: "\(owner) (\(what))", aspect: .declaredOrder,
                served: servedNames.joined(separator: ", "),
                design: designNames.joined(separator: ", "))
        ]
    }

    // MARK: Pieces

    private func text(_ type: Type) -> String { print(ast: type) }

    private func byName<Node>(_ nodes: [Node], _ key: KeyPath<Node, String>) -> [String: Node] {
        Dictionary(nodes.map { ($0[keyPath: key], $0) }) { first, _ in first }
    }

    private func union(_ first: some Sequence<String>, _ second: some Sequence<String>) -> [String]
    {
        Array(Set(first).union(second)).sorted()
    }

    private func quoted(_ text: String?) -> String {
        text.map { "\"\($0)\"" } ?? "none"
    }
}
