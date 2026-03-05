// swift-tools-version: 6.0

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
        .library(name: "MLXLMTokenizers", targets: ["MLXLMTokenizers"])
    ],
    dependencies: [
        // TODO: Change to ml-explore/mlx-swift-lm before PR #118 is merged
        .package(url: "https://github.com/DePasqualeOrg/mlx-swift-lm.git", branch: "swift-tokenizers"),
        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers.git", from: "0.2.0"),
        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api.git", from: "0.2.0"),
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
                .product(name: "IntegrationTestHelpers", package: "mlx-swift-lm"),
            ]
        ),
        .testTarget(
            name: "Benchmarks",
            dependencies: [
                "MLXLMTokenizers",
                "TestHelpers",
                .product(name: "BenchmarkHelpers", package: "mlx-swift-lm"),
            ]
        ),
    ]
)
