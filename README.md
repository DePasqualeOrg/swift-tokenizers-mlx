# Swift Tokenizers MLX

This package allows [Swift Tokenizers](https://github.com/DePasqualeOrg/swift-tokenizers) to seamlessly integrate with [MLX Swift LM](https://github.com/ml-explore/mlx-swift-lm) by providing protocol conformance and convenience overloads.

Refer to the [Benchmarks](#Benchmarks) section to compare the performance of Swift Tokenizers and Swift Transformers.

## Setup

Add this package alongside MLX Swift LM in your `Package.swift`:

```swift
.package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx/", from: "0.1.3", traits: ["Swift"]),
```

And add the module you need to your target's dependencies:

```swift
.product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx"),
// and/or
.product(name: "MLXEmbeddersTokenizers", package: "swift-tokenizers-mlx"),
```

## Tokenizer backend

Swift Tokenizers provides two backends using Swift package traits:

| | Swift (default) | Rust (opt-in) |
|---|---|---|
| Tokenization | Swift | [tokenizers](https://github.com/huggingface/tokenizers) |
| Chat templates | [Swift Jinja](https://github.com/huggingface/swift-jinja) | [MiniJinja](https://github.com/mitsuhiko/minijinja) |
| JSON parsing | [yyjson](https://github.com/ibireme/yyjson) (C) | [serde](https://github.com/serde-rs/serde) |

The opt-in `Rust` trait links a Rust binary and excludes the corresponding Swift implementations for even faster performance than the optimized Swift backend.

To opt into the Rust backend, enable the `Rust` trait on this package:

```swift
.package(
    url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx/",
    from: "0.1.3",
    traits: ["Rust"]
),
```

The package traits are mutually exclusive – do not combine `Swift` and `Rust`.

For Xcode projects, select the trait in the package dependency settings.

## Usage

`MLXLMTokenizers` provides convenience overloads with a default tokenizer loader, so you can omit the `using:` parameter:

```swift
import MLXLLM
import MLXLMHFAPI
import MLXLMTokenizers

// TokenizersLoader is used automatically
let model = try await loadModel(
    from: HubClient.default,
    id: "mlx-community/Qwen3-4B-4bit"
)
```

Load from a local directory:

```swift
import MLXLLM
import MLXLMTokenizers

let container = try await loadModelContainer(from: modelDirectory)
```

You can also pass `TokenizersLoader()` explicitly to the core API:

```swift
let container = try await loadModelContainer(
    from: HubClient.default,
    using: TokenizersLoader(),
    id: "mlx-community/Qwen3-4B-4bit"
)
```

For embedders, import `MLXEmbeddersTokenizers` to get the same default tokenizer behavior:

```swift
import MLXEmbedders
import MLXEmbeddersTokenizers
import MLXEmbeddersHFAPI

let container = try await loadModelContainer(
    from: HubClient.default,
    configuration: EmbedderRegistry.qwen3_embedding
)
```

## Testing

Benchmarks are included by default. Integration tests are opt-in and download models from Hugging Face on first run. The integration suite stays at roughly 5 GB or less per repository to avoid RAM issues on lower-memory devices.

### Running integration tests

In Xcode, set `TOKENIZERS_MLX_ENABLE_INTEGRATION_TESTS=1` in the test scheme environment. To run against the Rust backend, also enable the `Rust` trait under **File → Packages → Package Traits…**.

From the command line, run MLX-backed tests with `xcodebuild`. Two env vars are involved and they sit at different layers:

- `TEST_RUNNER_TOKENIZERS_MLX_ENABLE_INTEGRATION_TESTS=1` is the runtime suite gate; the `TEST_RUNNER_` prefix tells xcodebuild to forward the variable into the test host.
- `TOKENIZERS_BACKEND=Rust` flips the default trait at manifest-evaluation time, so it is set on the `xcodebuild` process itself rather than forwarded.

```bash
# Swift backend (default)
TEST_RUNNER_TOKENIZERS_MLX_ENABLE_INTEGRATION_TESTS=1 \
  xcodebuild test -scheme swift-tokenizers-mlx-Package -destination 'platform=macOS,arch=arm64' -only-testing:IntegrationTests

# Rust backend
TOKENIZERS_BACKEND=Rust \
  TEST_RUNNER_TOKENIZERS_MLX_ENABLE_INTEGRATION_TESTS=1 \
  xcodebuild test -scheme swift-tokenizers-mlx-Package -destination 'platform=macOS,arch=arm64' -only-testing:IntegrationTests
```

## Benchmarks

| | Swift Transformers | Swift backend | | Rust backend | |
| --- | ---: | ---: | --- | ---: | --- |
| Tokenizer load | 399.3 ms | 174.4 ms | 2.3x faster | 167.4 ms | 2.4x faster |
| Tokenization | 48.4 ms | 23.4 ms | 2.1x faster | 3.5 ms | 13.8x faster |
| Decoding | 30.9 ms | 14.9 ms | 2.1x faster | 3.7 ms | 8.4x faster |
| LLM load | 409.7 ms | 191.0 ms | 2.1x faster | 181.4 ms | 2.3x faster |
| VLM load | 441.6 ms | 234.0 ms | 1.9x faster | 226.3 ms | 2.0x faster |
| Embedding load | 412.0 ms | 202.1 ms | 2.0x faster | 194.4 ms | 2.1x faster |

These results were observed on an M3 MacBook Pro using Swift Tokenizers [`0.4.2`](https://github.com/DePasqualeOrg/swift-tokenizers/releases/tag/0.4.2), Swift Transformers [`1.3.0`](https://github.com/huggingface/swift-transformers/releases/tag/1.3.0), and MLX Swift LM [`3.31.3`](https://github.com/ml-explore/mlx-swift-lm/releases/tag/3.31.3).

### Running benchmarks

The benchmarks use tests from MLX Swift LM and can be run from this package in Xcode or from the command line with `xcodebuild`. `xcodebuild` does not support `--traits`, so setting `TOKENIZERS_BACKEND=Rust` flips the package's default trait at manifest-evaluation time to let xcodebuild drive the Rust backend:

```bash
# Swift backend (default)
xcodebuild test -scheme swift-tokenizers-mlx-Package -configuration Release -destination 'platform=macOS,arch=arm64' -only-testing:Benchmarks

# Rust backend
TOKENIZERS_BACKEND=Rust xcodebuild test -scheme swift-tokenizers-mlx-Package -configuration Release -destination 'platform=macOS,arch=arm64' -only-testing:Benchmarks
```
