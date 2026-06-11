// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-tokenizers-mlx",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "MLXLMTokenizers", targets: ["MLXLMTokenizers"]),
        .library(name: "MLXEmbeddersTokenizers", targets: ["MLXEmbeddersTokenizers"]),
    ],
    dependencies: [
        // TODO: Pin to a tagged release once the fork publishes one. A branch dependency
        // blocks versioned consumers, so no new version tags of this package until then.
        .package(url: "https://github.com/DePasqualeOrg/mlx-swift-lm.git", branch: "main"),
        // Minor releases of swift-tokenizers have been API-breaking; bump deliberately.
        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers.git", .upToNextMinor(from: "0.7.0")),
        // 0.4.1 is the floor: its artifactbundle localizes non-FFI Rust globals, fixing
        // duplicate-symbol link failures alongside other Rust-backed packages.
        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api.git", .upToNextMinor(from: "0.4.1")),
    ],
    targets: [
        .target(
            name: "MLXLMTokenizers",
            dependencies: [
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "Tokenizers", package: "swift-tokenizers"),
            ]
        ),
        .target(
            name: "MLXEmbeddersTokenizers",
            dependencies: [
                .product(name: "MLXEmbedders", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                "MLXLMTokenizers",
            ]
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "HFAPI", package: "swift-hf-api"),
            ],
            path: "Tests/TestHelpers"
        ),
        .testTarget(
            name: "Benchmarks",
            dependencies: [
                "MLXLMTokenizers",
                "MLXEmbeddersTokenizers",
                "TestHelpers",
                .product(name: "HFAPI", package: "swift-hf-api"),
                .product(name: "MLXEmbedders", package: "mlx-swift-lm"),
                .product(name: "BenchmarkHelpers", package: "mlx-swift-lm"),
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "MLXLMTokenizers",
                "TestHelpers",
                .product(name: "HFAPI", package: "swift-hf-api"),
                .product(name: "IntegrationTestHelpers", package: "mlx-swift-lm"),
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
            ]
        ),
    ]
)
