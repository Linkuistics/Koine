// Evidence only: what a compatible framework minor 1 adds to the baseline, under
// the evolution rules of docs/specs/machine.md ("Native extensions"). It is never
// part of the shipped framework, whose published interface is a permanent
// promise. scripts/build-compat-pairs.sh copies it into the newer revision's
// framework sources, and adds the `describeInstance` requirement to `Provider`
// there; a provider compiled against the baseline has no witness for it and
// gets this default.

extension Provider {
    public func describeInstance() -> String { "a provider built before framework minor 1" }
}

/// A new declaration: a plugin that uses it needs framework 1.1.
public func koineProviderMinor1Greeting(revision: Int) -> String {
    "hello from the fixture provider, revision \(revision), using framework minor 1"
}
