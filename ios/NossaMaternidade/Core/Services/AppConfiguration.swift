import Foundation

struct AppConfiguration {
    let supabaseURL: URL?
    let supabaseAnonKey: String
    let nathIAProxyURL: URL?
    let revenueCatAPIKey: String
    let revenueCatOfferingID: String
    let revenueCatEntitlementID: String
    let revenueCatYearlyProductID: String
    let photoBucket: String
    let termsURL: URL
    let privacyURL: URL

    static let current = AppConfiguration(
        supabaseURL: URL(string: ConfigReader.value("SUPABASE_URL")),
        supabaseAnonKey: ConfigReader.value("SUPABASE_ANON_KEY"),
        nathIAProxyURL: URL(string: ConfigReader.value("NATHIA_PROXY_URL")),
        revenueCatAPIKey: ConfigReader.value("REVENUECAT_API_KEY"),
        revenueCatOfferingID: ConfigReader.value("REVENUECAT_OFFERING_ID", fallback: "default"),
        revenueCatEntitlementID: ConfigReader.value("REVENUECAT_ENTITLEMENT_ID", fallback: "premium"),
        revenueCatYearlyProductID: ConfigReader.value("REVENUECAT_YEARLY_PRODUCT_ID"),
        photoBucket: ConfigReader.value("SUPABASE_PHOTO_BUCKET", fallback: "journal-photos"),
        termsURL: ConfigReader.url("TERMS_URL", fallback: "https://nossamaternidade.com.br/termos"),
        privacyURL: ConfigReader.url("PRIVACY_URL", fallback: "https://nossamaternidade.com.br/privacidade")
    )

    var hasSupabaseCredentials: Bool {
        supabaseURL != nil && !supabaseAnonKey.isEmpty
    }

    var hasNathIAProxyCredentials: Bool {
        nathIAProxyURL != nil && !supabaseAnonKey.isEmpty
    }

    var hasRevenueCatCredentials: Bool {
        !revenueCatAPIKey.isEmpty
    }
}

private enum ConfigReader {
    static func value(_ key: String, fallback: String = "") -> String {
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
           let sanitized = sanitize(value) {
            return sanitized
        }

        if let value = ProcessInfo.processInfo.environment[key],
           let sanitized = sanitize(value) {
            return sanitized
        }

        return fallback
    }

    static func url(_ key: String, fallback: String) -> URL {
        guard let fallbackURL = URL(string: fallback) else {
            return URL(fileURLWithPath: "/")
        }
        return URL(string: value(key, fallback: fallback)) ?? fallbackURL
    }

    private static func sanitize(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else {
            return nil
        }
        return trimmed
    }
}
