import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: String
    var name: String
    var stage: MaternalStage
    var babyName: String?
    var babyBirthDate: Date?
    var dueDate: Date?
    var createdAt: Date
    var hasCompletedOnboarding: Bool
    var prefersDarkModeAtNight: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String = "",
        stage: MaternalStage = .tryingToConceive,
        babyName: String? = nil,
        babyBirthDate: Date? = nil,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        hasCompletedOnboarding: Bool = false,
        prefersDarkModeAtNight: Bool = true
    ) {
        self.id = id
        self.name = name
        self.stage = stage
        self.babyName = babyName
        self.babyBirthDate = babyBirthDate
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.prefersDarkModeAtNight = prefersDarkModeAtNight
    }
}

enum MaternalStage: String, Codable, CaseIterable {
    case tryingToConceive = "tentando"
    case pregnant = "gravida"
    case newborn = "recem_nascido"
    case infant = "bebe"
    case toddler = "crianca"
    
    var displayName: String {
        switch self {
        case .tryingToConceive: return "Tentando engravidar"
        case .pregnant: return "Grávida"
        case .newborn: return "Recém-nascido (0-3 meses)"
        case .infant: return "Bebê (3-12 meses)"
        case .toddler: return "Criança (1+ ano)"
        }
    }
    
    var icon: String {
        switch self {
        case .tryingToConceive: return "heart.fill"
        case .pregnant: return "person.fill"
        case .newborn: return "moon.fill"
        case .infant: return "baby.fill"
        case .toddler: return "figure.and.child.holdinghands"
        }
    }
    
    var onboardingPrompt: String {
        switch self {
        case .tryingToConceive:
            return "Vamos juntas nessa jornada. Cada ciclo é uma nova esperança."
        case .pregnant:
            return "Que momento especial! Vou te acompanhar em cada semana."
        case .newborn:
            return "O quarto trimestre é intenso. Estou aqui com você, 24 horas."
        case .infant:
            return "Cada dia seu bebê descobre algo novo. E você também."
        case .toddler:
            return "Uma fase cheia de energia, descobertas e muito amor."
        }
    }
}
