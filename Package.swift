// swift-tools-version: 6.1

import PackageDescription

// Tokenizer backend to build against when working on this package directly
// (running integration tests, benchmarks, etc.). Defaults to "Swift"; set
// `TOKENIZERS_BACKEND=Rust` in the environment before running `swift test`
// or `xcodebuild test` to flip. Downstream consumers don't need to touch
// this — they select a trait on the swift-tokenizers-mlx dependency in
// their own Package.swift.
//
// The chosen value is applied in two places: as this package's default trait,
// and as the sole trait enabled on the swift-tokenizers dependency. Both are
// hardcoded at manifest-evaluation time rather than propagated via
// `.trait(name: condition:)` because SPM's conditional propagation is
// additive — it wouldn't override the dependency's own default trait,
// leaving both backends enabled at once.
let backendTrait = Context.environment["TOKENIZERS_BACKEND"] == "Rust" ? "Rust" : "Swift"

var packageTargets: [Target] = [
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
    traits: [
        .default(enabledTraits: [backendTrait]),
        .trait(name: "Swift"),
        .trait(name: "Rust"),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm.git", from: "3.31.3"),
        .package(
            url: "https://github.com/DePasqualeOrg/swift-tokenizers.git",
            from: "0.4.2",
            traits: [.init(name: backendTrait)]),
        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api.git", from: "0.2.2"),
    ],
    targets: packageTargets
)
