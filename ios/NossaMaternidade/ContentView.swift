import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(AppServices.self) private var services
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? {
        profiles.first
    }

    private var hasCompletedOnboarding: Bool {
        profile?.hasCompletedOnboarding == true
    }

    var body: some View {
        ZStack {
            AppTheme.ColorToken.backgroundPrimary.ignoresSafeArea()

            if hasCompletedOnboarding {
                MainTabView(profile: profile)
            } else {
                OnboardingView()
            }
        }
        .task {
            prepareApp()
        }
        .onChange(of: profile?.anonymousUserID) { _, userID in
            guard let userID else { return }
            services.subscriptions.configure(appUserID: userID)
        }
    }

    private func prepareApp() {
        if let userID = profile?.anonymousUserID {
            services.subscriptions.configure(appUserID: userID)
        }
    }
}

#Preview("Onboarding") {
    if let container = try? ModelContainer(
        for: UserProfile.self, ChatMessage.self, DailyUsage.self,
        WeeklyJournalEntry.self, SubscriptionRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        ContentView()
            .environment(AppServices())
            .modelContainer(container)
            .environment(\.locale, Locale(identifier: "pt_BR"))
    } else {
        Text("Preview indisponível")
    }
}
