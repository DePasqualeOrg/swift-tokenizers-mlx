// Copyright © Anthony DePasquale

import Foundation
import MLXLMCommon
import Tokenizers

/// Bridges swift-tokenizers' `Tokenizer` to `MLXLMCommon.Tokenizer`.
///
/// `AutoTokenizer.from()` returns `any Tokenizers.Tokenizer`, which is a different
/// protocol from `MLXLMCommon.Tokenizer`. This wrapper adapts the upstream type
/// to the local protocol.
struct TokenizerBridge: MLXLMCommon.Tokenizer {
    private let upstream: any Tokenizers.Tokenizer

    init(_ upstream: any Tokenizers.Tokenizer) {
        self.upstream = upstream
    }

    func encode(text: String, addSpecialTokens: Bool) throws -> [Int] {
        try upstream.encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokenIds: [Int], skipSpecialTokens: Bool) throws -> String {
        try upstream.decode(tokenIds: tokenIds, skipSpecialTokens: skipSpecialTokens)
    }

    func convertTokenToId(_ token: String) -> Int? {
        upstream.convertTokenToId(token)
    }

    func convertIdToToken(_ id: Int) -> String? {
        upstream.convertIdToToken(id)
    }

    var bosToken: String? { upstream.bosToken }
    var eosToken: String? { upstream.eosToken }
    var unknownToken: String? { upstream.unknownToken }

    func applyChatTemplate(
        messages: [[String: any Sendable]],
        tools: [[String: any Sendable]]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        do {
            return try upstream.applyChatTemplate(
                messages: messages, tools: tools, additionalContext: additionalContext)
        } catch Tokenizers.TokenizerError.missingChatTemplate {
            throw MLXLMCommon.TokenizerError.missingChatTemplate
        }
    }
}

/// Bridges an upstream tokenizer that supports cleanup-free raw decoding to
/// `MLXLMCommon.StreamingDecodeTokenizer`, so `MLXLMCommon.StreamingDetokenizer`
/// can use the raw decode path during streaming generation.
///
/// This is a separate wrapper rather than a conformance on `TokenizerBridge`
/// because `rawDecode` promises cleanup-free, byte-prefix-monotonic output;
/// only upstreams that conform to `Tokenizers.StreamingDecodeTokenizer` can
/// keep that promise.
struct StreamingTokenizerBridge: MLXLMCommon.StreamingDecodeTokenizer {
    private let base: TokenizerBridge
    private let upstream: any Tokenizers.StreamingDecodeTokenizer

    init(_ upstream: any Tokenizers.StreamingDecodeTokenizer) {
        self.upstream = upstream
        base = TokenizerBridge(upstream)
    }

    func encode(text: String, addSpecialTokens: Bool) throws -> [Int] {
        try base.encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokenIds: [Int], skipSpecialTokens: Bool) throws -> String {
        try base.decode(tokenIds: tokenIds, skipSpecialTokens: skipSpecialTokens)
    }

    func rawDecode(tokenIds: [Int], skipSpecialTokens: Bool) throws -> String {
        try upstream.rawDecode(tokenIds: tokenIds, skipSpecialTokens: skipSpecialTokens)
    }

    func convertTokenToId(_ token: String) -> Int? {
        base.convertTokenToId(token)
    }

    func convertIdToToken(_ id: Int) -> String? {
        base.convertIdToToken(id)
    }

    var bosToken: String? { base.bosToken }
    var eosToken: String? { base.eosToken }
    var unknownToken: String? { base.unknownToken }

    func applyChatTemplate(
        messages: [[String: any Sendable]],
        tools: [[String: any Sendable]]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        try base.applyChatTemplate(
            messages: messages, tools: tools, additionalContext: additionalContext)
    }
}

/// Loads a tokenizer from a local directory using swift-tokenizers' `AutoTokenizer`.
public struct TokenizersLoader: TokenizerLoader {
    public init() {}

    public func load(from directory: URL) async throws -> any MLXLMCommon.Tokenizer {
        let upstream = try await AutoTokenizer.from(directory: directory)
        if let streaming = upstream as? any Tokenizers.StreamingDecodeTokenizer {
            return StreamingTokenizerBridge(streaming)
        }
        return TokenizerBridge(upstream)
    }
}
