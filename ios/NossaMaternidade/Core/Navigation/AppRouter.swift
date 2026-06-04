import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case nathIA
    case diary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Início"
        case .nathIA: return "NathIA"
        case .diary: return "Diário"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .nathIA: return "bubble.left.and.bubble.right.fill"
        case .diary: return "book.closed.fill"
        }
    }
}
