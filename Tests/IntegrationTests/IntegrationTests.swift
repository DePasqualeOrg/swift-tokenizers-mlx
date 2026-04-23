import Foundation
import HFAPI
import IntegrationTestHelpers
import MLXLLM
import MLXLMTokenizers
import TestHelpers
import Testing

private let integrationTestsEnabled =
    ProcessInfo.processInfo.environment["TOKENIZERS_MLX_ENABLE_INTEGRATION_TESTS"] == "1"

private let models = IntegrationTestModels(
    downloader: HubClient.default, tokenizerLoader: TokenizersLoader())

@Suite(.serialized, .enabled(if: integrationTestsEnabled))
struct IntegrationTests {

    // MARK: - ChatSession

    @Test func oneShot() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.oneShot(container: container)
    }

    @Test func oneShotStream() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.oneShotStream(container: container)
    }

    @Test func multiTurnConversation() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.multiTurnConversation(container: container)
    }

    @Test func visionModel() async throws {
        let container = try await models.vlmContainer(for: .init(id: IntegrationTestModelIDs.vlm))
        try await ChatSessionTests.visionModel(container: container)
    }

    @Test func streamDetailsWithTools() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.streamDetailsWithTools(container: container)
    }

    @Test func toolInvocation() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.toolInvocation(container: container)
    }

    @Test func promptRehydration() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.llm))
        try await ChatSessionTests.promptRehydration(container: container)
    }

    // MARK: - Embedder

    @Test func embedderReadmeExample() async throws {
        try await EmbedderTests.readmeExample(container: models.embeddingContainer())
    }

    // MARK: - Tool Calls

    @Test func lfm2FormatAutoDetection() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.lfm2))
        try await ToolCallTests.lfm2FormatAutoDetection(container: container)
    }

    @Test func lfm2EndToEndGeneration() async throws {
        let container = try await models.llmContainer(for: .init(id: IntegrationTestModelIDs.lfm2))
        try await ToolCallTests.lfm2EndToEndGeneration(container: container)
    }

    // Keep integration models at roughly 5 GB or less per repo.
    // Larger models can exhaust RAM and crash lower-memory devices during load or inference.

    @Test func mistral3FormatAutoDetection() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.mistral3))
        try await ToolCallTests.mistral3FormatAutoDetection(container: container)
    }

    @Test func mistral3EndToEndGeneration() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.mistral3))
        try await ToolCallTests.mistral3EndToEndGeneration(container: container)
    }

    @Test func mistral3MultiToolGeneration() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.mistral3))
        try await ToolCallTests.mistral3MultiToolGeneration(container: container)
    }

    @Test func qwen35FormatAutoDetection() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.qwen35))
        try await ToolCallTests.qwen35FormatAutoDetection(container: container)
    }

    @Test func qwen35EndToEndGeneration() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.qwen35))
        try await ToolCallTests.qwen35EndToEndGeneration(container: container)
    }

    @Test func qwen35MultiToolGeneration() async throws {
        let container = try await models.llmContainer(
            for: .init(id: IntegrationTestModelIDs.qwen35))
        try await ToolCallTests.qwen35MultiToolGeneration(container: container)
    }
}

@Suite(.serialized, .enabled(if: integrationTestsEnabled))
struct CoherenceIntegrationTests {

    @Test func bitnet_b1_58_2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.bitnet_b1_58_2b_4t_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func exaone_4_0_1_2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.exaone_4_0_1_2b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func gemma3_1B_qat() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.gemma3_1B_qat_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func gemma3n_E2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.gemma3n_E2B_it_lm_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func gemma4_e2b() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.gemma4_e2b_it_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func glm4_9B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.glm4_9b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func granite3_3_2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.granite3_3_2b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func granite4_0_H_tiny() async throws {
        let container = try await models.llmContainer(
            for: LLMRegistry.granite_4_0_h_tiny_4bit_dwq)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func jamba_3B_4bit() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.jamba_3b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func lfm2_1_2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.lfm2_1_2b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func llama3_2_1B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.llama3_2_1B_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func mistral_7B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.mistral7B4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func olmo2_7B() async throws {
        let container = try await models.llmContainer(
            for: LLMRegistry.olmo_2_1124_7B_Instruct_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func olmoe_1B_7B() async throws {
        let container = try await models.llmContainer(
            for: LLMRegistry.olmoe_1b_7b_0125_instruct_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func phi3_5() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.phi3_5_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func qwen3_1_7B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.qwen3_1_7b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func qwen3_5_2B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.qwen3_5_2b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }

    @Test func smollm3_3B() async throws {
        let container = try await models.llmContainer(for: LLMRegistry.smollm3_3b_4bit)
        try await ChatSessionTests.planetsCoherence(container: container)
    }
}
