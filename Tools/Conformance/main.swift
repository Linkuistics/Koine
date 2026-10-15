import Foundation
import GraphQL
import KoineConformanceCheck
import KoineCore

// The conformance check of docs/specs/machine.md's "Public GraphQL contract":
// the schema a running Koine actually serves, against the agreed design SDL.
//
// It reads an introspection response captured from a running application (the
// host never launches Koine — scripts/vm-verify-conformance.sh captures it in a
// VM), rebuilds the SDL that response describes, prints it through KoineCore's
// own canonical printer, and compares the result with the design contract by
// type, field, argument, nullability, default, deprecation, description and
// declared order.
//
// A clean result has to be two things at once, and neither alone would do:
//
//   * the digest of the canonically printed DESIGN text equals the digest Koine
//     served. It is computed by the same code in KoineCore that the server
//     computes it with, and it needs nothing from introspection — so it says the
//     design file is exactly the schema Koine hashed, declared order included.
//   * the difference report against the INTROSPECTED schema is empty, which says
//     the same thing from the public seam and says *where* when it is not.
//
// Together they cannot be satisfied by a lossy capture: anything introspection
// dropped that the design declares is reported as a difference, and anything the
// design lacks that Koine serves moves the digest.
//
// --expect-differences <n> makes a run assert a number instead, which is how the
// positive control watches a mutated design SDL turn the check red.

struct Options {
    var introspection: String?
    var design = "docs/design/desktop-schema-extension-host.graphql"
    var servedDigest: String?
    var sdlOut: String?
    var expectDifferences: Int?
    var profile: String?
    var providers: String?
}

func usage() -> Never {
    let text = """
        Usage: KoineConformance --introspection <file.json> [options]

        Compares the schema of a captured introspection response with the design
        contract, and checks the printed served schema against the digest the
        server reported.

        Options:
          --introspection <file>   the introspection response, as the server answered it
          --design <file>          the design SDL (default docs/design/desktop-schema-extension-host.graphql)
          --profile <file>         a conformance profile (docs/design/profiles/): its design SDL
                                   replaces --design, and --providers is then required
          --providers <file>       the koineManagement.providers response the profile pins
          --served-digest <hex>    Koine.schemaDigest read in the same session; checked
          --sdl-out <file>         write the canonical served SDL here
          --expect-differences <n> exit 0 only when exactly n differences are found
          --print-query            print the introspection query this check asks, and stop

        Exit status: 0 conformant (or as expected), 1 differences found, 2 unusable input.
        """
    FileHandle.standardError.write(Data((text + "\n").utf8))
    exit(2)
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data(("Error: " + message + "\n").utf8))
    exit(2)
}

var options = Options()
var arguments = Array(CommandLine.arguments.dropFirst())
while let flag = arguments.first {
    arguments.removeFirst()
    func value() -> String {
        guard let next = arguments.first else { fail("\(flag) needs a value.") }
        arguments.removeFirst()
        return next
    }
    switch flag {
    case "--introspection": options.introspection = value()
    case "--design": options.design = value()
    case "--profile": options.profile = value()
    case "--providers": options.providers = value()
    case "--served-digest": options.servedDigest = value()
    case "--sdl-out": options.sdlOut = value()
    case "--expect-differences":
        guard let count = Int(value()) else { fail("--expect-differences needs a number.") }
        options.expectDifferences = count
    case "--print-query":
        print(IntrospectionQuery.text)
        exit(0)
    case "-h", "--help": usage()
    default: fail("unknown option \(flag).")
    }
}

guard let introspectionPath = options.introspection else { usage() }

// A profile names the design SDL, so it is resolved before the design is read.
var profile: ConformanceProfile?
var servedProviders: [[String: String?]] = []
if let path = options.profile {
    guard let providersPath = options.providers else {
        fail("--profile pins candidate versions, so it needs --providers <file>.")
    }
    do {
        let loaded = try ConformanceProfile.load(from: URL(fileURLWithPath: path))
        profile = loaded.profile
        options.design = loaded.design.path
        servedProviders = try ConformanceProfile.servedRows(
            fromJSON: Data(contentsOf: URL(fileURLWithPath: providersPath)))
    } catch {
        fail("cannot read the profile \(path) or the providers \(providersPath): \(error)")
    }
} else if options.providers != nil {
    fail("--providers is read against a profile; name one with --profile.")
}

let introspectionData: Data
do {
    introspectionData = try Data(contentsOf: URL(fileURLWithPath: introspectionPath))
} catch {
    fail("cannot read \(introspectionPath): \(error)")
}
let designText: String
do {
    designText = try String(contentsOfFile: options.design, encoding: .utf8)
} catch {
    fail("cannot read \(options.design): \(error)")
}

let servedSDL: String
do {
    servedSDL = try IntrospectionSDL.sdl(fromIntrospectionResponse: introspectionData)
} catch {
    fail("\(error)")
}

// Both sides through one pipeline: SDL text -> schema -> canonical print. The
// comparison below then reads exactly the bytes the digest is taken over.
let servedCanonical: String
let designCanonical: String
do {
    servedCanonical = try CanonicalSchemaText.canonicalText(ofSDL: servedSDL)
} catch {
    fail("the introspected schema does not rebuild: \(error)")
}
do {
    designCanonical = try CanonicalSchemaText.canonicalText(ofSDL: designText)
} catch {
    fail("\(options.design) is not a schema this can build: \(error)")
}

if let path = options.sdlOut {
    do {
        try (servedCanonical + "\n").write(toFile: path, atomically: true, encoding: .utf8)
    } catch {
        fail("cannot write \(path): \(error)")
    }
}

let designDigest = CanonicalSchemaText.digest(ofCanonicalText: designCanonical)
var digestAgrees = true
print("digest of \(options.design), canonically printed: \(designDigest)")
if let reported = options.servedDigest {
    print("digest Koine served (Koine.schemaDigest):      \(reported)")
    digestAgrees = reported == designDigest
    print(
        digestAgrees
            ? "  they agree: the design file is exactly the schema Koine hashed."
            : "  they differ: the design file is not the schema Koine hashed.")
} else {
    print("  (no --served-digest given: the digest half of this check did not run)")
}

let differences: [SchemaDifference]
do {
    differences = SchemaComparison(
        served: try parse(source: servedCanonical), design: try parse(source: designCanonical)
    ).differences()
} catch {
    fail("a canonical text does not parse back: \(error)")
}
print("")
if differences.isEmpty {
    print("The served schema matches \(options.design) exactly.")
} else {
    print("\(differences.count) difference(s) between the served schema and \(options.design):")
    print("")
    for difference in differences { print(difference.report) }
}

// The candidates are pinned apart from the schema: an identical digest cannot
// prove which binary ran.
var profileProblems: [String] = []
if let profile {
    profileProblems = profile.problems(inServed: servedProviders)
    print("")
    if profileProblems.isEmpty {
        print("The providers served match the profile \"\(profile.name)\": \(profile.providers.count) candidate(s), pinned.")
    } else {
        print("\(profileProblems.count) profile problem(s) for \"\(profile.name)\":")
        for problem in profileProblems { print("  \(problem)") }
    }
}

if let expected = options.expectDifferences {
    print("")
    guard differences.count == expected else {
        FileHandle.standardError.write(
            Data("Error: expected \(expected) difference(s), found \(differences.count).\n".utf8))
        exit(1)
    }
    print("As expected: \(expected) difference(s).")
    exit(0)
}

print("")
if differences.isEmpty, digestAgrees, profileProblems.isEmpty {
    print("CONFORMANT: the schema Koine serves is \(options.design)\(profile.map { ", as profile \"\($0.name)\"" } ?? "").")
    exit(0)
}
if differences.isEmpty, digestAgrees, !profileProblems.isEmpty {
    print("NOT CONFORMANT: the schema is the design SDL, but the candidates served are not the profile's.")
}
// Order is the one difference only the digest can see, so say so rather than
// letting a digest-only failure read as an unexplained one.
if differences.isEmpty, !digestAgrees {
    print(
        """
        NOT CONFORMANT: every type, field, argument, nullability, default,
        deprecation and description agrees, but the digests do not. What the
        introspected text cannot carry is the DECLARED ORDER of object and input
        fields, so that is what differs — compare the order of the fields in
        \(options.design) with the order Koine composes them in (the core's own
        fields, then each provider's, docs/specs/machine.md "Composition and
        operation placement").
        """)
}
exit(1)
