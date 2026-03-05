# Swift Tokenizers MLX

This package allows [Swift Tokenizers](https://github.com/DePasqualeOrg/swift-tokenizers) to seamlessly integrate with [MLX Swift LM](https://github.com/ml-explore/mlx-swift-lm) by providing protocol conformance and convenience overloads.

## Setup

Add this package alongside mlx-swift-lm in your `Package.swift`:

```swift
.package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx/", from: "0.1.0"),
```

And add `MLXLMTokenizers` to your target's dependencies:

```swift
.product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx"),
```

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

## Re-exports

`MLXLMTokenizers` re-exports `MLXLMCommon`, so you get access to the full mlx-swift-lm API without an additional import.

## Testing

Integration tests for inference and benchmarks for model loading are included.
