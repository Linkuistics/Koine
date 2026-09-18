import GraphQL

/// Enforces a `RequestPolicy` on query text and on a parsed document. Nothing
/// here runs a resolver or consults the schema, so an over-limit request is
/// rejected before validation and before any provider callback.
struct RequestLimits {
    struct Exceeded: Error {
        let message: String
    }

    let policy: RequestPolicy

    // MARK: Before parsing

    /// Rejects query text whose brackets nest deeper than the policy allows.
    /// Strings, block strings and comments are skipped as the lexer skips them.
    func checkSyntaxNesting(of source: String) throws {
        let bytes = Array(source.utf8)
        let quote = UInt8(ascii: "\""), backslash = UInt8(ascii: "\\")
        let newline = UInt8(ascii: "\n"), carriageReturn = UInt8(ascii: "\r")
        func isTripleQuote(at index: Int) -> Bool {
            index + 2 < bytes.count && bytes[index] == quote && bytes[index + 1] == quote
                && bytes[index + 2] == quote
        }

        var depth = 0
        var index = 0
        while index < bytes.count {
            let byte = bytes[index]
            switch byte {
            case UInt8(ascii: "#"):
                while index < bytes.count, bytes[index] != newline, bytes[index] != carriageReturn {
                    index += 1
                }
                continue
            case quote where isTripleQuote(at: index):
                index += 3
                while index < bytes.count, !isTripleQuote(at: index) {
                    // `\"""` is the block string's only escape.
                    index += bytes[index] == backslash && isTripleQuote(at: index + 1) ? 4 : 1
                }
                index += 3
                continue
            case quote:
                index += 1
                while index < bytes.count, bytes[index] != quote, bytes[index] != newline {
                    index += bytes[index] == backslash ? 2 : 1
                }
                index += 1
                continue
            case UInt8(ascii: "{"), UInt8(ascii: "["), UInt8(ascii: "("):
                depth += 1
                guard depth <= policy.maximumSyntaxNesting else {
                    throw Exceeded(
                        message: "Query nests brackets deeper than \(policy.maximumSyntaxNesting)."
                    )
                }
            case UInt8(ascii: "}"), UInt8(ascii: "]"), UInt8(ascii: ")"):
                depth = max(0, depth - 1)
            default:
                break
            }
            index += 1
        }
    }

    // MARK: After parsing

    /// Checks depth and expanded selection count for every operation in the
    /// document. `@skip`/`@include` are ignored: a selection counts whether or
    /// not it would execute, so the check can only over-deny.
    func check(_ document: Document) throws {
        var walk = Walk(policy: policy)
        for case let fragment as FragmentDefinition in document.definitions {
            walk.fragments[fragment.name.value] = fragment
        }
        for case let operation as OperationDefinition in document.definitions {
            let size = try walk.measure(operation.selectionSet, depth: 0, hops: 0)
            guard size.selections <= policy.maximumFieldSelections else {
                throw Exceeded(
                    message: "Operation selects more than \(policy.maximumFieldSelections) fields."
                )
            }
        }
    }

    func checkRootMutationActions(_ count: Int) throws {
        guard count <= policy.maximumRootMutationActions else {
            throw Exceeded(
                message:
                    "Mutation requests more than \(policy.maximumRootMutationActions) root actions."
            )
        }
    }

    private struct Size {
        var selections = 0
        /// Field levels below the point of measurement.
        var depth = 0
    }

    /// Fragments are measured once and reused at every spread, so a document
    /// whose expansion is exponential in its length costs time linear in it.
    private struct Walk {
        /// Counts saturate here: far above any limit, far below overflow.
        static let saturation = 1 << 40

        let policy: RequestPolicy
        var fragments: [String: FragmentDefinition] = [:]
        var measured: [String: Size] = [:]
        var expanding: Set<String> = []

        /// `depth` is the field depth of `selectionSet`'s parent. `hops` counts
        /// the fragment spreads and inline fragments on the way here; bounding
        /// it, with `depth`, bounds this function's own recursion.
        mutating func measure(_ selectionSet: SelectionSet, depth: Int, hops: Int) throws -> Size {
            guard hops <= policy.maximumSyntaxNesting else {
                throw Exceeded(
                    message: "Query chains fragments deeper than \(policy.maximumSyntaxNesting)."
                )
            }
            var total = Size()
            for selection in selectionSet.selections {
                var part = Size()
                switch selection {
                case let field as Field:
                    guard depth + 1 <= policy.maximumDepth else { throw tooDeep }
                    if let children = field.selectionSet {
                        part = try measure(children, depth: depth + 1, hops: hops)
                    }
                    part.selections += 1
                    part.depth += 1
                case let inline as InlineFragment:
                    part = try measure(inline.selectionSet, depth: depth, hops: hops + 1)
                case let spread as FragmentSpread:
                    let name = spread.name.value
                    if let known = measured[name] {
                        part = known
                    } else if let fragment = fragments[name], expanding.insert(name).inserted {
                        part = try measure(fragment.selectionSet, depth: depth, hops: hops + 1)
                        expanding.remove(name)
                        measured[name] = part
                    }
                    // Otherwise a cycle or an unknown fragment, which adds
                    // nothing here and which validation rejects.
                    guard depth + part.depth <= policy.maximumDepth else { throw tooDeep }
                default:
                    continue
                }
                total.selections = min(total.selections + part.selections, Self.saturation)
                total.depth = max(total.depth, part.depth)
            }
            return total
        }

        private var tooDeep: Exceeded {
            Exceeded(message: "Query nests fields deeper than \(policy.maximumDepth).")
        }
    }
}
