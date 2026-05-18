import Foundation
import SwiftData

@Model
final class TrackerLog {
    @Attribute(.unique) var id: String
    var createdAt: Date
    var category: TrackerCategory
    var value: Double
    var notes: String
    var unit: String
    
    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        category: TrackerCategory,
        value: Double,
        notes: String = "",
        unit: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.value = value
        self.notes = notes
        self.unit = unit
    }
}

enum TrackerCategory: String, Codable, CaseIterable {
    case feeding = "alimentacao"
    case sleep = "sono"
    case diaper = "fralda"
    case pumping = "extracao"
    case medication = "medicacao"
    case temperature = "temperatura"
    case weight = "peso"
    case mood = "humor"
    case milestone = "marco"
    
    var displayName: String {
        switch self {
        case .feeding: return "Alimentação"
        case .sleep: return "Sono"
        case .diaper: return "Fralda"
        case .pumping: return "Extração"
        case .medication: return "Medicação"
        case .temperature: return "Temperatura"
        case .weight: return "Peso"
        case .mood: return "Humor"
        case .milestone: return "Marco"
        }
    }
    
    var icon: String {
        switch self {
        case .feeding: return "fork.knife"
        case .sleep: return "moon.fill"
        case .diaper: return "drop.fill"
        case .pumping: return "arrow.down.circle.fill"
        case .medication: return "pills.fill"
        case .temperature: return "thermometer"
        case .weight: return "scalemass.fill"
        case .mood: return "face.smiling"
        case .milestone: return "star.fill"
        }
    }
    
    var defaultUnit: String {
        switch self {
        case .feeding: return "min"
        case .sleep: return "min"
        case .diaper: return ""
        case .pumping: return "ml"
        case .medication: return "mg"
        case .temperature: return "°C"
        case .weight: return "kg"
        case .mood: return ""
        case .milestone: return ""
        }
    }
    
    var quickActions: [QuickAction] {
        switch self {
        case .feeding:
            return [
                QuickAction(label: "Mama", value: 15, unit: "min"),
                QuickAction(label: "Mamadeira", value: 120, unit: "ml"),
                QuickAction(label: "Papa", value: 1, unit: "refeição")
            ]
        case .sleep:
            return [
                QuickAction(label: "Cochilo", value: 30, unit: "min"),
                QuickAction(label: "Sono longo", value: 120, unit: "min")
            ]
        case .diaper:
            return [
                QuickAction(label: "Xixi", value: 1, unit: ""),
                QuickAction(label: "Cocô", value: 1, unit: ""),
                QuickAction(label: "Misto", value: 1, unit: "")
            ]
        case .pumping:
            return [
                QuickAction(label: "60ml", value: 60, unit: "ml"),
                QuickAction(label: "120ml", value: 120, unit: "ml")
            ]
        default:
            return []
        }
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let unit: String
}
