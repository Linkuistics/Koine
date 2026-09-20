// swift-tools-version:6.2
import PackageDescription

// Library choices and their verification are recorded in README.md ("Dependencies").
let package = Package(
    name: "Koine",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "KoineCore", targets: ["KoineCore"]),
        .library(name: "KoineServer", targets: ["KoineServer"]),
    ],
    dependencies: [
        // The resilient provider framework; its own package so it is one
        // dynamic image, never linked statically into a host target.
        .package(path: "ProviderAPI"),
        .package(url: "https://github.com/GraphQLSwift/GraphQL.git", from: "4.2.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.103.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "5.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.11.1"),
    ],
    targets: [
        // The Machine core: no macOS, client or concrete-provider dependency.
        // GraphQL-library types never appear in its public interface.
        .target(
            name: "KoineCore",
            dependencies: [
                .product(name: "KoineProviderAPI", package: "ProviderAPI"),
                .product(name: "GraphQL", package: "GraphQL"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        // The native loader: dlopen and Objective-C class lookup live here,
        // outside the core.
        .target(
            name: "KoineProviderLoader",
            dependencies: [.product(name: "KoineProviderAPI", package: "ProviderAPI")]
        ),
        .target(
            name: "KoineSQLiteStore",
            dependencies: ["KoineCore", .product(name: "GRDB", package: "GRDB.swift")]
        ),
        .target(
            name: "KoineHTTP",
            dependencies: [
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]
        ),
        .target(
            name: "KoineServer",
            dependencies: ["KoineCore", "KoineSQLiteStore", "KoineHTTP", "KoineProviderLoader"]
        ),
        // What the native UI knows of the server: GraphQL through the console.
        .target(name: "KoineManagementClient", dependencies: ["KoineServer"]),
        // The resident application. Platform UI frameworks live only here.
        // scripts/build-app.sh assembles and signs Koine.app around it.
        .executableTarget(
            name: "KoineApp",
            dependencies: ["KoineCore", "KoineServer", "KoineManagementClient", "KoineProviderLoader"]
        ),
        // The conformance check (task conformance, scripts/vm-verify-conformance.sh):
        // the schema a running Koine serves, against docs/design/desktop-schema.graphql.
        // It prints the served schema through KoineCore's own canonical printer;
        // GraphQL is a dependency here for the structural comparison alone. The
        // library is where the tests reach it; scripts/build-app.sh ships neither.
        .target(
            name: "KoineConformanceCheck",
            dependencies: ["KoineCore", .product(name: "GraphQL", package: "GraphQL")]
        ),
        .executableTarget(
            name: "KoineConformance",
            dependencies: [
                "KoineConformanceCheck", "KoineCore",
                .product(name: "GraphQL", package: "GraphQL"),
            ],
            path: "Tools/Conformance"
        ),
        // Test material: the headless host of the binary compatibility pairs
        // (scripts/build-compat-pairs.sh). scripts/build-app.sh does not ship it.
        .executableTarget(
            name: "KoineCompatibilityHost", dependencies: ["KoineServer"],
            path: "Fixtures/CompatibilityHost"
        ),
        // The desktop provider's pure files, named here only so `swift test`
        // reaches them. The provider itself is built by its own build definition
        // (Providers/DesktopProvider/build.sh) and is no product of this package.
        .target(name: "DesktopProviderLogic", path: "Providers/DesktopProvider/Logic"),
        .testTarget(name: "DesktopProviderLogicTests", dependencies: ["DesktopProviderLogic"]),
        .testTarget(
            name: "KoineManagementClientTests",
            dependencies: ["KoineManagementClient", "KoineServer", "KoineCore"]
        ),
        .testTarget(
            name: "KoineServerTests",
            dependencies: [
                "KoineServer", "KoineCore", "KoineSQLiteStore", "KoineProviderLoader",
                "KoineConformanceCheck",
                // For in-test descriptors; the fixture bundle is built elsewhere.
                .product(name: "KoineProviderAPI", package: "ProviderAPI"),
            ]
        ),
    ]
)
