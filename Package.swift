// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-tokenizers-mlx",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "MLXLMTokenizers", targets: ["MLXLMTokenizers"]),
        .library(name: "MLXEmbeddersTokenizers", targets: ["MLXEmbeddersTokenizers"]),
    ],
    dependencies: [
        // TODO: Switch from this pinned revision to a major-version dependency once mlx-swift-lm publishes a release that includes PR #118.
        .package(url: "https://github.com/ml-explore/mlx-swift-lm.git", revision: "8c9dd6391139242261bcf27d253c326f9cf2d567"),
        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers.git", from: "0.3.1"),
        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api.git", from: "0.2.2"),
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
            name: "IntegrationTests",
            dependencies: [
                "MLXLMTokenizers",
                "TestHelpers",
                .product(name: "HFAPI", package: "swift-hf-api"),
                .product(name: "IntegrationTestHelpers", package: "mlx-swift-lm"),
            ]
        ),
        .testTarget(
            name: "Benchmarks",
            dependencies: [
                "MLXLMTokenizers",
                "TestHelpers",
                .product(name: "HFAPI", package: "swift-hf-api"),
                .product(name: "BenchmarkHelpers", package: "mlx-swift-lm"),
            ]
        ),
    ]
)
