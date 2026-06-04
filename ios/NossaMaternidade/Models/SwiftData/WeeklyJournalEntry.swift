import Foundation
import SwiftData

@Model
final class WeeklyJournalEntry {
    @Attribute(.unique) var id: String
    var userID: String
    var pregnancyWeek: Int
    var mood: String
    var symptoms: [String]
    var note: String
    var localPhotoURI: String?
    var remotePhotoURL: String?
    var syncStatus: SyncStatus
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        userID: String,
        pregnancyWeek: Int,
        mood: String,
        symptoms: [String] = [],
        note: String = "",
        localPhotoURI: String? = nil,
        remotePhotoURL: String? = nil,
        syncStatus: SyncStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.pregnancyWeek = pregnancyWeek
        self.mood = mood
        self.symptoms = symptoms
        self.note = note
        self.localPhotoURI = localPhotoURI
        self.remotePhotoURL = remotePhotoURL
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum JournalMood: String, CaseIterable, Identifiable {
    case sereia
    case onda
    case raio
    case folha
    case fogo

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sereia: return "sereia"
        case .onda: return "onda"
        case .raio: return "raio"
        case .folha: return "folha"
        case .fogo: return "fogo"
        }
    }

    var symbolName: String {
        switch self {
        case .sereia: return "sparkles"
        case .onda: return "water.waves"
        case .raio: return "bolt.fill"
        case .folha: return "leaf.fill"
        case .fogo: return "flame.fill"
        }
    }
}
