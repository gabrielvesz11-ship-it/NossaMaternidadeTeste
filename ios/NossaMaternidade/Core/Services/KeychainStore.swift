import Foundation
import Security

enum KeychainKey: String {
    case supabaseAccessToken
    case supabaseAnonymousUserID
}

enum KeychainStore {
    static func save(_ value: String, for key: KeychainKey) {
        guard let data = value.data(using: .utf8) else { return }
        let query = baseQuery(for: key)
        SecItemDelete(query as CFDictionary)

        var item = query
        item[kSecValueData as String] = data
        SecItemAdd(item as CFDictionary, nil)
    }

    static func load(_ key: KeychainKey) -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private static func baseQuery(for key: KeychainKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "NossaMaternidade",
            kSecAttrAccount as String: key.rawValue
        ]
    }
}
