import Foundation

struct SupabaseSession {
    let userID: String
    let accessToken: String?
}

enum SupabaseServiceError: LocalizedError {
    case missingConfiguration
    case invalidURL
    case emptyAuthSession
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Supabase ainda não foi configurado."
        case .invalidURL:
            return "URL do Supabase inválida."
        case .emptyAuthSession:
            return "Não foi possível criar a sessão anônima."
        case .requestFailed(let message):
            return message
        }
    }
}

final class SupabaseService {
    private let configuration: AppConfiguration
    private let session = URLSession.shared
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    init(configuration: AppConfiguration) {
        self.configuration = configuration
    }

    func signInAnonymously() async throws -> SupabaseSession {
        guard configuration.hasSupabaseCredentials else {
            return SupabaseSession(userID: UUID().uuidString, accessToken: nil)
        }

        let response: AuthResponse = try await perform(
            path: "auth/v1/signup",
            method: "POST",
            bearerToken: configuration.supabaseAnonKey,
            body: AuthRequest(data: AuthMetadata(platform: "ios"))
        )

        guard let userID = response.user?.id else {
            throw SupabaseServiceError.emptyAuthSession
        }

        if let accessToken = response.accessToken {
            KeychainStore.save(accessToken, for: .supabaseAccessToken)
        }
        KeychainStore.save(userID, for: .supabaseAnonymousUserID)

        return SupabaseSession(userID: userID, accessToken: response.accessToken)
    }

    func ensureAnonymousSession() async throws -> SupabaseSession {
        if let userID = KeychainStore.load(.supabaseAnonymousUserID),
           let accessToken = KeychainStore.load(.supabaseAccessToken) {
            return SupabaseSession(userID: userID, accessToken: accessToken)
        }

        return try await signInAnonymously()
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        let payload = ProfilePayload(profile: profile)
        try await performWithoutResponse(
            path: "rest/v1/profiles",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            bearerToken: authBearerToken,
            prefer: "resolution=merge-duplicates,return=minimal",
            body: payload
        )
    }

    func insertChatMessage(_ message: ChatMessage) async throws {
        try await performWithoutResponse(
            path: "rest/v1/chat_messages",
            method: "POST",
            bearerToken: authBearerToken,
            prefer: "return=minimal",
            body: ChatMessagePayload(message: message)
        )
    }

    func upsertDailyUsage(_ usage: DailyUsage) async throws {
        try await performWithoutResponse(
            path: "rest/v1/daily_usage",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            bearerToken: authBearerToken,
            prefer: "resolution=merge-duplicates,return=minimal",
            body: DailyUsagePayload(usage: usage)
        )
    }

    func upsertJournalEntry(_ entry: WeeklyJournalEntry) async throws {
        try await performWithoutResponse(
            path: "rest/v1/weekly_journal_entries",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            bearerToken: authBearerToken,
            prefer: "resolution=merge-duplicates,return=minimal",
            body: JournalEntryPayload(entry: entry)
        )
    }

    func upsertSubscription(_ subscription: SubscriptionRecord) async throws {
        try await performWithoutResponse(
            path: "rest/v1/subscriptions",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            bearerToken: authBearerToken,
            prefer: "resolution=merge-duplicates,return=minimal",
            body: SubscriptionPayload(subscription: subscription)
        )
    }

    func uploadJournalPhoto(localURL: URL, userID: String, entryID: String) async throws -> String {
        guard configuration.hasSupabaseCredentials else {
            throw SupabaseServiceError.missingConfiguration
        }

        let data = try Data(contentsOf: localURL)
        let objectPath = "\(userID)/\(entryID).jpg"
        let path = "storage/v1/object/\(configuration.photoBucket)/\(objectPath)"
        var request = try baseRequest(path: path, method: "POST", bearerToken: authBearerToken)
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "x-upsert")
        request.httpBody = data

        let (_, response) = try await session.data(for: request)
        try validate(response: response, fallbackMessage: "Não foi possível enviar a foto.")
        return "\(configuration.photoBucket)/\(objectPath)"
    }

    private var authBearerToken: String {
        KeychainStore.load(.supabaseAccessToken) ?? configuration.supabaseAnonKey
    }

    private func perform<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        bearerToken: String,
        prefer: String? = nil,
        body: Body
    ) async throws -> Response {
        var request = try baseRequest(path: path, method: method, queryItems: queryItems, bearerToken: bearerToken)
        if let prefer {
            request.setValue(prefer, forHTTPHeaderField: "Prefer")
        }
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data, fallbackMessage: "Falha ao conectar com o Supabase.")
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private func performWithoutResponse<Body: Encodable>(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        bearerToken: String,
        prefer: String? = nil,
        body: Body
    ) async throws {
        guard configuration.hasSupabaseCredentials else {
            throw SupabaseServiceError.missingConfiguration
        }

        var request = try baseRequest(path: path, method: method, queryItems: queryItems, bearerToken: bearerToken)
        if let prefer {
            request.setValue(prefer, forHTTPHeaderField: "Prefer")
        }
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data, fallbackMessage: "Falha ao sincronizar com o Supabase.")
    }

    private func baseRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        bearerToken: String
    ) throws -> URLRequest {
        guard let baseURL = configuration.supabaseURL else {
            throw SupabaseServiceError.missingConfiguration
        }

        var url = baseURL.appendingPathComponent(path)
        if !queryItems.isEmpty {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw SupabaseServiceError.invalidURL
            }
            components.queryItems = queryItems
            guard let componentURL = components.url else {
                throw SupabaseServiceError.invalidURL
            }
            url = componentURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(configuration.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validate(response: URLResponse, data: Data = Data(), fallbackMessage: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.requestFailed(fallbackMessage)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = SupabaseErrorMessage.from(data: data) ?? fallbackMessage
            throw SupabaseServiceError.requestFailed(message)
        }
    }
}

private struct AuthRequest: Encodable {
    let data: AuthMetadata
}

private struct AuthMetadata: Encodable {
    let platform: String
}

private struct AuthResponse: Decodable {
    let accessToken: String?
    let user: SupabaseUser?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

private struct SupabaseUser: Decodable {
    let id: String
}

private struct ProfilePayload: Encodable {
    let id: String
    let anonymous_user_id: String
    let name: String
    let due_date: String?
    let is_first_pregnancy: Bool
    let created_at: Date
    let updated_at: Date

    init(profile: UserProfile) {
        self.id = profile.id
        self.anonymous_user_id = profile.anonymousUserID
        self.name = profile.name
        self.due_date = profile.dueDate.map { DateFormatter.localDayKey.string(from: $0) }
        self.is_first_pregnancy = profile.isFirstPregnancy
        self.created_at = profile.createdAt
        self.updated_at = profile.updatedAt
    }
}

private struct ChatMessagePayload: Encodable {
    let id: String
    let user_id: String
    let role: String
    let content: String
    let created_at: Date

    init(message: ChatMessage) {
        self.id = message.id
        self.user_id = message.userID
        self.role = message.role.rawValue
        self.content = message.content
        self.created_at = message.createdAt
    }
}

private struct DailyUsagePayload: Encodable {
    let id: String
    let user_id: String
    let date: String
    let nathia_message_count: Int
    let created_at: Date
    let updated_at: Date

    init(usage: DailyUsage) {
        self.id = usage.id
        self.user_id = usage.userID
        self.date = usage.dayKey
        self.nathia_message_count = usage.nathiaMessageCount
        self.created_at = usage.createdAt
        self.updated_at = usage.updatedAt
    }
}

private struct JournalEntryPayload: Encodable {
    let id: String
    let user_id: String
    let pregnancy_week: Int
    let mood: String
    let symptoms: [String]
    let note: String
    let local_photo_uri: String?
    let remote_photo_url: String?
    let sync_status: String
    let created_at: Date
    let updated_at: Date

    init(entry: WeeklyJournalEntry) {
        self.id = entry.id
        self.user_id = entry.userID
        self.pregnancy_week = entry.pregnancyWeek
        self.mood = entry.mood
        self.symptoms = entry.symptoms
        self.note = entry.note
        self.local_photo_uri = entry.localPhotoURI
        self.remote_photo_url = entry.remotePhotoURL
        self.sync_status = entry.syncStatus.rawValue
        self.created_at = entry.createdAt
        self.updated_at = entry.updatedAt
    }
}

private struct SubscriptionPayload: Encodable {
    let id: String
    let user_id: String
    let revenuecat_customer_id: String
    let entitlement: String
    let status: String
    let expires_at: Date?
    let updated_at: Date

    init(subscription: SubscriptionRecord) {
        self.id = subscription.id
        self.user_id = subscription.userID
        self.revenuecat_customer_id = subscription.revenuecatCustomerID
        self.entitlement = subscription.entitlement
        self.status = subscription.status.rawValue
        self.expires_at = subscription.expiresAt
        self.updated_at = subscription.updatedAt
    }
}

private struct SupabaseErrorMessage: Decodable {
    let message: String?
    let errorDescription: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case message
        case errorDescription = "error_description"
        case error
    }

    static func from(data: Data) -> String? {
        guard let decoded = try? JSONDecoder().decode(SupabaseErrorMessage.self, from: data) else {
            return nil
        }
        return decoded.message ?? decoded.errorDescription ?? decoded.error
    }
}
