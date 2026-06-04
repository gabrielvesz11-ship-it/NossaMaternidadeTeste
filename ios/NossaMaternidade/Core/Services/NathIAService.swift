import Foundation

enum NathIAServiceError: LocalizedError, Equatable {
    case missingConfiguration
    case emptyResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "A NathIA ainda precisa do endpoint seguro do Supabase."
        case .emptyResponse:
            return "A NathIA não conseguiu responder agora."
        case .requestFailed(let message):
            return message
        }
    }
}

final class NathIAService {
    private let configuration: AppConfiguration
    private let session: URLSession
    private let authTokenProvider: () -> String?

    init(
        configuration: AppConfiguration,
        session: URLSession = .shared,
        authTokenProvider: @escaping () -> String? = { KeychainStore.load(.supabaseAccessToken) }
    ) {
        self.configuration = configuration
        self.session = session
        self.authTokenProvider = authTokenProvider
    }

    func send(messages: [ChatMessage]) async throws -> String {
        guard configuration.hasNathIAProxyCredentials,
              let endpoint = configuration.nathIAProxyURL else {
            throw NathIAServiceError.missingConfiguration
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(configuration.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(NathIAProxyRequest(messages: messages.suffix(16).map(NathIAProxyMessage.init)))

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        let decoded = try JSONDecoder().decode(NathIAProxyResponse.self, from: data)
        let text = decoded.message.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            throw NathIAServiceError.emptyResponse
        }

        return text
    }

    private var bearerToken: String {
        let token = authTokenProvider()?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let token, !token.isEmpty {
            return token
        }
        return configuration.supabaseAnonKey
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NathIAServiceError.requestFailed("Não consegui falar com a NathIA agora.")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = NathIAProxyErrorResponse.from(data: data) ?? "A NathIA oscilou um pouquinho. Tenta de novo daqui a pouco."
            throw NathIAServiceError.requestFailed(message)
        }
    }
}

private struct NathIAProxyRequest: Encodable {
    let messages: [NathIAProxyMessage]
}

private struct NathIAProxyMessage: Encodable {
    let role: String
    let content: String

    init(message: ChatMessage) {
        self.role = message.role.rawValue
        self.content = message.content
    }
}

private struct NathIAProxyResponse: Decodable {
    let message: String
}

private struct NathIAProxyErrorResponse: Decodable {
    let message: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case message
        case error
        case errorDescription = "error_description"
    }

    static func from(data: Data) -> String? {
        guard let response = try? JSONDecoder().decode(NathIAProxyErrorResponse.self, from: data) else {
            return nil
        }
        return response.message ?? response.errorDescription ?? response.error
    }
}
