import Foundation

struct PostDTO: Identifiable, Codable {
    var id: String?
    let authorID: String
    let authorName: String
    let authorStage: String
    let content: String
    let createdAt: Date
    let likes: Int
    let replyCount: Int
    let tags: [String]
    let isAnonymous: Bool
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct ReplyDTO: Identifiable, Codable {
    var id: String?
    let authorID: String
    let authorName: String
    let content: String
    let createdAt: Date
    let isAnonymous: Bool
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

enum CommunityTag: String, CaseIterable {
    case all = "todos"
    case support = "apoio"
    case question = "duvida"
    case milestone = "marco"
    case vent = "desabafo"
    case tip = "dica"
    
    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .support: return "Apoio"
        case .question: return "Dúvida"
        case .milestone: return "Marco"
        case .vent: return "Desabafo"
        case .tip: return "Dica"
        }
    }
}
