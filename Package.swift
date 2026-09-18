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
                .product(name: "GraphQL", package: "GraphQL"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .target(
            name: "KoineSQLiteStore",
            dependencies: ["KoineCore", .product(name: "GRDB", package: "GRDB.swift")]
        ),
        .target(
            name: "KoineHTTP",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]
        ),
        .target(
            name: "KoineServer",
            dependencies: ["KoineCore", "KoineSQLiteStore", "KoineHTTP"]
        ),
        .testTarget(
            name: "KoineServerTests",
            dependencies: ["KoineServer", "KoineCore", "KoineSQLiteStore"]
        ),
    ]
)
