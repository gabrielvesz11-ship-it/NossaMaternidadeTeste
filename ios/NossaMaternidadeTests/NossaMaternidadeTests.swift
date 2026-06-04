import Foundation
import Testing
@testable import NossaMaternidade

struct PregnancyCalculatorTests {
    @Test func currentWeekReturnsNilWithoutDueDate() {
        #expect(PregnancyCalculator.currentWeek(dueDate: nil) == nil)
    }

    @Test func currentWeekStartsAtOneAtPregnancyStart() {
        let today = date(year: 2026, month: 5, day: 19)
        let dueDate = Calendar.current.date(byAdding: .day, value: 280, to: today)

        #expect(PregnancyCalculator.currentWeek(dueDate: dueDate, today: today) == 1)
    }

    @Test func currentWeekClampsToFortyOnDueDate() {
        let today = date(year: 2026, month: 5, day: 19)

        #expect(PregnancyCalculator.currentWeek(dueDate: today, today: today) == 40)
    }

    @Test func currentWeekReturnsNilBeforePregnancyWindow() {
        let today = date(year: 2026, month: 5, day: 19)
        let dueDate = Calendar.current.date(byAdding: .day, value: 281, to: today)

        #expect(PregnancyCalculator.currentWeek(dueDate: dueDate, today: today) == nil)
    }

    @Test func babySizeTextUsesFallbackWithoutWeek() {
        let text = PregnancyCalculator.babySizeText(for: nil)

        #expect(text == "Hoje seu bebê segue crescendo no tempo dele.")
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }
}

struct AppConfigurationTests {
    @Test func nathIAProxyRequiresProxyURLAndSupabaseAnonKey() {
        let configured = AppConfiguration(
            supabaseURL: URL(string: "https://project.supabase.co"),
            supabaseAnonKey: "anon-key",
            nathIAProxyURL: URL(string: "https://project.supabase.co/functions/v1/nath-ai"),
            revenueCatAPIKey: "",
            revenueCatOfferingID: "default",
            revenueCatEntitlementID: "premium",
            revenueCatYearlyProductID: "",
            photoBucket: "journal-photos",
            termsURL: testURL("https://example.com/termos"),
            privacyURL: testURL("https://example.com/privacidade")
        )

        let missingProxy = AppConfiguration(
            supabaseURL: URL(string: "https://project.supabase.co"),
            supabaseAnonKey: "anon-key",
            nathIAProxyURL: nil,
            revenueCatAPIKey: "",
            revenueCatOfferingID: "default",
            revenueCatEntitlementID: "premium",
            revenueCatYearlyProductID: "",
            photoBucket: "journal-photos",
            termsURL: testURL("https://example.com/termos"),
            privacyURL: testURL("https://example.com/privacidade")
        )

        #expect(configured.hasNathIAProxyCredentials)
        #expect(!missingProxy.hasNathIAProxyCredentials)
    }
}

struct NathIAServiceTests {
    @Test func sendPostsChatMessagesToConfiguredSupabaseProxy() async throws {
        let endpoint = testURL("https://project.supabase.co/functions/v1/nath-ai")
        let service = NathIAService(
            configuration: testConfiguration(nathIAProxyURL: endpoint),
            session: MockURLProtocol.session(statusCode: 200, body: #"{"message":"Respira. Estou aqui."}"#),
            authTokenProvider: { "session-token" }
        )

        let response = try await service.send(messages: [
            ChatMessage(userID: "user-1", role: .user, content: "Estou ansiosa")
        ])

        #expect(response == "Respira. Estou aqui.")
        #expect(MockURLProtocol.lastRequest?.url == endpoint)
        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "apikey") == "anon-key")
        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer session-token")
        #expect(MockURLProtocol.lastBodyString?.contains("Estou ansiosa") == true)
        #expect(MockURLProtocol.lastBodyString?.contains("claude") == false)
    }

    @Test func sendThrowsTypedErrorForEmptyProxyMessage() async throws {
        let service = NathIAService(
            configuration: testConfiguration(),
            session: MockURLProtocol.session(statusCode: 200, body: #"{"message":"   "}"#),
            authTokenProvider: { "session-token" }
        )

        await #expect(throws: NathIAServiceError.emptyResponse) {
            _ = try await service.send(messages: [
                ChatMessage(userID: "user-1", role: .user, content: "Oi")
            ])
        }
    }

    @Test func sendSurfacesProxyErrorMessage() async throws {
        let service = NathIAService(
            configuration: testConfiguration(),
            session: MockURLProtocol.session(statusCode: 401, body: #"{"message":"Sessão inválida"}"#),
            authTokenProvider: { "session-token" }
        )

        await #expect(throws: NathIAServiceError.requestFailed("Sessão inválida")) {
            _ = try await service.send(messages: [
                ChatMessage(userID: "user-1", role: .user, content: "Oi")
            ])
        }
    }
}

struct SubscriptionServiceTests {
    @Test func startsUnknownAndMovesToErrorWhenRevenueCatConfigIsMissing() async {
        let service = SubscriptionService(configuration: testConfiguration(revenueCatAPIKey: ""))

        #expect(service.state == .unknown)

        await #expect(throws: SubscriptionServiceError.missingConfiguration) {
            try await service.refreshEntitlement()
        }
        #expect(service.state.isError)
    }

    @Test func activeStatusesUnlockPremiumAccess() {
        #expect(SubscriptionAccessState.active.isPremium)
        #expect(SubscriptionAccessState.trial.isPremium)
        #expect(!SubscriptionAccessState.free.isPremium)
        #expect(!SubscriptionAccessState.expired.isPremium)
        #expect(!SubscriptionAccessState.unknown.isPremium)
    }
}

private func testConfiguration(
    nathIAProxyURL: URL? = URL(string: "https://project.supabase.co/functions/v1/nath-ai"),
    revenueCatAPIKey: String = "rc_public_key"
) -> AppConfiguration {
    AppConfiguration(
        supabaseURL: URL(string: "https://project.supabase.co"),
        supabaseAnonKey: "anon-key",
        nathIAProxyURL: nathIAProxyURL,
        revenueCatAPIKey: revenueCatAPIKey,
        revenueCatOfferingID: "default",
        revenueCatEntitlementID: "premium",
        revenueCatYearlyProductID: "premium_yearly",
        photoBucket: "journal-photos",
        termsURL: testURL("https://example.com/termos"),
        privacyURL: testURL("https://example.com/privacidade")
    )
}

private func testURL(_ value: String) -> URL {
    URL(string: value) ?? URL(fileURLWithPath: "/")
}

private final class MockURLProtocol: URLProtocol {
    private static var responseStatusCode = 200
    private static var responseBody = Data()
    static var lastRequest: URLRequest?
    static var lastBodyString: String?

    static func session(statusCode: Int, body: String) -> URLSession {
        responseStatusCode = statusCode
        responseBody = Data(body.utf8)
        lastRequest = nil
        lastBodyString = nil

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequest = request
        Self.lastBodyString = request.httpBody.map { String(decoding: $0, as: UTF8.self) }

        guard let url = request.url,
              let response = HTTPURLResponse(
            url: url,
            statusCode: Self.responseStatusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
              ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseBody)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
