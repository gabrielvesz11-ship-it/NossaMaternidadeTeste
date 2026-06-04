import Foundation
import SwiftData

@Model
final class DailyUsage {
    @Attribute(.unique) var id: String
    var userID: String
    var dayKey: String
    var nathiaMessageCount: Int
    var createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus

    init(
        id: String = UUID().uuidString,
        userID: String,
        dayKey: String = DateFormatter.localDayKey.string(from: Date()),
        nathiaMessageCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.userID = userID
        self.dayKey = dayKey
        self.nathiaMessageCount = nathiaMessageCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

extension DateFormatter {
    static let localDayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
