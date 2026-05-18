import Foundation
import SwiftData
import SwiftUI

@Model
final class JournalEntry {
    @Attribute(.unique) var id: String
    var createdAt: Date
    var updatedAt: Date
    var mood: MoodRating
    var title: String
    var body: String
    var tags: [String]
    var isBookmarked: Bool
    var photoData: Data?
    
    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mood: MoodRating = .neutral,
        title: String = "",
        body: String = "",
        tags: [String] = [],
        isBookmarked: Bool = false,
        photoData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mood = mood
        self.title = title
        self.body = body
        self.tags = tags
        self.isBookmarked = isBookmarked
        self.photoData = photoData
    }
}

enum MoodRating: String, Codable, CaseIterable {
    case terrible = "terrivel"
    case bad = "ruim"
    case neutral = "neutro"
    case good = "bom"
    case great = "otimo"
    
    var emoji: String {
        switch self {
        case .terrible: return "😢"
        case .bad: return "😕"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .great: return "🤗"
        }
    }
    
    var label: String {
        switch self {
        case .terrible: return "Muito difícil"
        case .bad: return "Difícil"
        case .neutral: return "Mais ou menos"
        case .good: return "Bem"
        case .great: return "Muito bem"
        }
    }
    
    var color: Color {
        switch self {
        case .terrible: return Color(hex: "C75B5B")
        case .bad: return Color(hex: "D4A656")
        case .neutral: return Color(hex: "A89E9A")
        case .good: return Color(hex: "8FA68E")
        case .great: return Color(hex: "6B9E75")
        }
    }
}
