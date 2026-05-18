import SwiftUI

enum AppRoute: Hashable {
    case onboarding
    case main
    case panic
    case nossaLuz
    case journalEditor(entryID: String?)
    case postDetail(postID: String)
    case profile
}

@Observable
final class AppRouter {
    var path = NavigationPath()
    var selectedTab: Tab = .community
    var showPanicSheet = false
    var showNossaLuzSheet = false
    
    enum Tab: String, CaseIterable {
        case community = "comunidade"
        case tracker = "registros"
        case journal = "diario"
        
        var icon: String {
            switch self {
            case .community: return "heart.text.square.fill"
            case .tracker: return "chart.bar.fill"
            case .journal: return "book.closed.fill"
            }
        }
        
        var title: String {
            switch self {
            case .community: return "Comunidade"
            case .tracker: return "Registros"
            case .journal: return "Diário"
            }
        }
    }
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func resetToRoot() {
        path.removeLast(path.count)
    }
}
