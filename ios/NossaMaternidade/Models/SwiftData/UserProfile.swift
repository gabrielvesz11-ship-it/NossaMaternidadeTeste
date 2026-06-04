import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: String
    var anonymousUserID: String
    var name: String
    var dueDate: Date?
    var isFirstPregnancy: Bool

    // Rich onboarding data (new in v2)
    var currentMoment: String?
    var mainPains: [String]?
    var desiredFeelings: [String]?
    var babyName: String?
    var createdAt: Date
    var updatedAt: Date
    var hasCompletedOnboarding: Bool
    var syncStatus: SyncStatus

    init(
        id: String = UUID().uuidString,
        anonymousUserID: String = UUID().uuidString,
        name: String = "",
        dueDate: Date? = nil,
        isFirstPregnancy: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        hasCompletedOnboarding: Bool = false,
        syncStatus: SyncStatus = .pending,
        currentMoment: String? = nil,
        mainPains: [String]? = nil,
        desiredFeelings: [String]? = nil,
        babyName: String? = nil
    ) {
        self.id = id
        self.anonymousUserID = anonymousUserID
        self.name = name
        self.dueDate = dueDate
        self.isFirstPregnancy = isFirstPregnancy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.syncStatus = syncStatus
        self.currentMoment = currentMoment
        self.mainPains = mainPains
        self.desiredFeelings = desiredFeelings
        self.babyName = babyName
    }
}

enum SyncStatus: String, Codable, CaseIterable {
    case pending
    case syncing
    case synced
    case failed
}
