import Foundation
import SwiftData

@Model
final class ChatMessage {
    @Attribute(.unique) var id: String
    var userID: String
    var role: ChatRole
    var content: String
    var createdAt: Date
    var syncStatus: SyncStatus

    init(
        id: String = UUID().uuidString,
        userID: String,
        role: ChatRole,
        content: String,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.userID = userID
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

enum ChatRole: String, Codable, CaseIterable {
    case user
    case assistant
}
