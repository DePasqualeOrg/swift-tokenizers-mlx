# Swift Tokenizers MLX

This package allows [Swift Tokenizers](https://github.com/DePasqualeOrg/swift-tokenizers) to seamlessly integrate with [MLX Swift LM](https://github.com/ml-explore/mlx-swift-lm) by providing protocol conformance and convenience overloads.

Refer to the [Benchmarks](#Benchmarks) section to compare the performance of Swift Tokenizers and Swift Transformers.

## Setup

Add this package alongside MLX Swift LM in your `Package.swift`:

```swift
.package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx/", from: "0.1.0"),
```

And add the module you need to your target's dependencies:

```swift
.product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx"),
// and/or
.product(name: "MLXEmbeddersTokenizers", package: "swift-tokenizers-mlx"),
```

## Tokenizer backend

Swift Tokenizers supports two backends behind the same API:

- **Swift** (default): Swift implementation with a C dependency (yyjson) for JSON parsing.
- **Rust**: uses a prebuilt Rust binary for faster tokenization and decoding. Includes its own JSON parser and Jinja template engine.

By default the Swift backend is used. To opt into the Rust backend, enable the `Rust` trait on this package:

```swift
.package(
    url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx/",
    from: "0.1.2",
    traits: ["Rust"]
),
```

The two backends are mutually exclusive – do not combine `Swift` and `Rust`.

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
    configuration: .nomic_text_v1_5
)
```

## Testing

Integration tests for inference and benchmarks are included.

## Benchmarks

The benchmarks use tests from MLX Swift LM and can be run from this package in Xcode.

These results were observed on an M3 MacBook Pro.

| Benchmark | Swift Tokenizers median | Swift Transformers median | Swift Tokenizers Performance |
| --- | ---: | ---: | --- |
| Tokenizer load | 289.6 ms | 1004.6 ms | 3.47x faster |
| Tokenization | 53.0 ms | 105.8 ms | 2.00x faster |
| Decoding | 28.9 ms | 48.4 ms | 1.67x faster |
| LLM load | 318.8 ms | 1033.5 ms | 3.24x faster |
| VLM load | 367.9 ms | 1081.5 ms | 2.94x faster |
| Embedding load | 310.7 ms | 1023.5 ms | 3.29x faster |
