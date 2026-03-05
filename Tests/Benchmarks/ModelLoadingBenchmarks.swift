import BenchmarkHelpers
import HFAPI
import MLXLMTokenizers
import TestHelpers
import Testing

@Suite(.serialized)
struct ModelLoadingBenchmarks {

    @Test func loadLLM() async throws {
        let stats = try await benchmarkLLMLoading(
            from: HubClient.default,
            using: TokenizersLoader()
        )
        stats.printSummary(label: "LLM load (swift-tokenizers)")
    }

    @Test func loadVLM() async throws {
        let stats = try await benchmarkVLMLoading(
            from: HubClient.default,
            using: TokenizersLoader()
        )
        stats.printSummary(label: "VLM load (swift-tokenizers)")
    }

    @Test func loadEmbedding() async throws {
        let stats = try await benchmarkEmbeddingLoading(
            from: HubClient.default,
            using: TokenizersLoader()
        )
        stats.printSummary(label: "Embedding load (swift-tokenizers)")
    }
}
