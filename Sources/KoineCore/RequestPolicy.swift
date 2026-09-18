/// The versioned request/response limits of the transport contract
/// (docs/specs/machine.md, "Local transport and discovery"). Every limit the
/// server enforces is a value here; nothing else carries a limit literal.
///
/// The limits bound what Koine accepts and how long it waits to answer. They
/// are not a promise to interrupt native code or to undo an action.
public struct RequestPolicy: Sendable, Equatable {
    /// Changes whenever a value of the published policy changes.
    public var version: Int
    /// Largest accepted HTTP request body.
    public var maximumBodyBytes: Int
    /// Deepest bracket nesting (`{`, `[`, `(`) accepted in the query text. It
    /// is checked before parsing, because the parser recurses without a bound
    /// of its own; it is generous enough never to bind before `maximumDepth`
    /// on selections, and also bounds input-value literals.
    public var maximumSyntaxNesting: Int
    /// Deepest field nesting, fragments expanded.
    public var maximumDepth: Int
    /// Most field selections in one operation, fragments expanded.
    public var maximumFieldSelections: Int
    /// Most root mutation actions in one request.
    public var maximumRootMutationActions: Int
    /// Largest response body Koine will send.
    public var maximumResponseBytes: Int
    /// How long a caller waits for execution. On expiry the execution task is
    /// cancelled cooperatively and the caller is answered at once; a resolver
    /// that does not observe cancellation keeps running, and an action that
    /// already began may still complete.
    public var executionDeadline: Duration

    public static let version1 = RequestPolicy(
        version: 1,
        maximumBodyBytes: 1 << 20,
        maximumSyntaxNesting: 64,
        maximumDepth: 16,
        maximumFieldSelections: 1_000,
        maximumRootMutationActions: 10,
        maximumResponseBytes: 8 << 20,
        executionDeadline: .seconds(5)
    )
}
