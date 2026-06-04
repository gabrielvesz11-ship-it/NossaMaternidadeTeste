import SwiftData
import SwiftUI

@main
struct NossaMaternidadeApp: App {
    private let modelContainerResult: Result<ModelContainer, Error> = {
        let schema = Schema([
            UserProfile.self,
            ChatMessage.self,
            DailyUsage.self,
            WeeklyJournalEntry.self,
            SubscriptionRecord.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return .success(try ModelContainer(for: schema, configurations: [configuration]))
        } catch {
            return .failure(error)
        }
    }()

    @State private var appServices = AppServices()

    var body: some Scene {
        WindowGroup {
            switch modelContainerResult {
            case .success(let modelContainer):
                ContentView()
                    .environment(appServices)
                    .environment(\.locale, Locale(identifier: "pt_BR"))
                    .modelContainer(modelContainer)
            case .failure(let error):
                StartupErrorView(message: error.localizedDescription)
                    .environment(\.locale, Locale(identifier: "pt_BR"))
            }
        }
    }
}

private struct StartupErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.orange)

            Text("Não foi possível iniciar o app.")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}
