import Foundation
import SwiftData

@Model
final class SubscriptionRecord {
    @Attribute(.unique) var id: String
    var userID: String
    var revenuecatCustomerID: String
    var entitlement: String
    var status: SubscriptionStatus
    var expiresAt: Date?
    var updatedAt: Date
    var syncStatus: SyncStatus

    init(
        id: String = UUID().uuidString,
        userID: String,
        revenuecatCustomerID: String = "",
        entitlement: String = "premium",
        status: SubscriptionStatus = .inactive,
        expiresAt: Date? = nil,
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.userID = userID
        self.revenuecatCustomerID = revenuecatCustomerID
        self.entitlement = entitlement
        self.status = status
        self.expiresAt = expiresAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

enum SubscriptionStatus: String, Codable, CaseIterable {
    case active
    case inactive
    case trial
    case expired
}
