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
            dependencies: ["KoineServer", "KoineManagementClient", "KoineProviderLoader"]
        ),
        // Test material: the headless host of the binary compatibility pairs
        // (scripts/build-compat-pairs.sh). scripts/build-app.sh does not ship it.
        .executableTarget(
            name: "KoineCompatibilityHost", dependencies: ["KoineServer"],
            path: "Fixtures/CompatibilityHost"
        ),
        .testTarget(
            name: "KoineManagementClientTests",
            dependencies: ["KoineManagementClient", "KoineServer"]
        ),
        .testTarget(
            name: "KoineServerTests",
            dependencies: [
                "KoineServer", "KoineCore", "KoineSQLiteStore", "KoineProviderLoader",
                // For in-test descriptors; the fixture bundle is built elsewhere.
                .product(name: "KoineProviderAPI", package: "ProviderAPI"),
            ]
        ),
    ]
)
