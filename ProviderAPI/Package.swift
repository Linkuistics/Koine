// swift-tools-version:6.2
import PackageDescription

// The provider binary interface (docs/adr/resilient-provider-framework.md). It
// is its own package so the root package links its dynamic product: a target of
// the root package would be linked statically into every host image. The flags
// apply in debug and release; README.md ("Provider framework") records why they
// are explicit flags and how the result was verified.
let installName = "@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI"

let package = Package(
    name: "KoineProviderAPI",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "KoineProviderAPI", type: .dynamic, targets: ["KoineProviderAPI"])
    ],
    targets: [
        .target(
            name: "KoineProviderAPI",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-install_name", "-Xlinker", installName])
            ]
        )
    ]
)
