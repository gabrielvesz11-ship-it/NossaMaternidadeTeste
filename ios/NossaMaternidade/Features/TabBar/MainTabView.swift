import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [SubscriptionRecord]
    let profile: UserProfile?
    @State private var selectedTab: AppTab = .home
    @State private var showPaywall = false

    private var isPremium: Bool {
        services.subscriptions.isPremium || subscriptions.contains { record in
            record.status == .active || record.status == .trial
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(profile: profile, openNathIA: openNathIA)
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            NathIAChatView(
                profile: profile,
                isPremium: isPremium,
                requestPaywall: requestPaywall
            )
            .tabItem { Label(AppTab.nathIA.title, systemImage: AppTab.nathIA.icon) }
            .tag(AppTab.nathIA)

            TrackerView(profile: profile, isPremium: isPremium)
                .tabItem { Label(AppTab.diary.title, systemImage: AppTab.diary.icon) }
                .tag(AppTab.diary)
        }
        .tint(AppTheme.ColorToken.accentPrimary)
        .sheet(isPresented: $showPaywall) {
            PaywallView(onUnlocked: markPremiumUnlocked)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task {
            await prepareSubscriptionState()
        }
    }

    private func openNathIA() {
        AppHaptics.selection()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            selectedTab = .nathIA
        }
    }

    private func requestPaywall() {
        guard !isPremium else { return }
        showPaywall = true
    }

    private func prepareSubscriptionState() async {
        guard let profile else { return }
        services.subscriptions.configure(appUserID: profile.anonymousUserID)
        try? await services.subscriptions.refreshEntitlement()
        await syncProfileIfNeeded(profile)
        syncPendingSubscriptions()

        if shouldTriggerDayThreePaywall(for: profile), !isPremium {
            showPaywall = true
        }
    }

    private func syncProfileIfNeeded(_ profile: UserProfile) async {
        guard profile.syncStatus == .pending || profile.syncStatus == .failed else { return }

        do {
            if let session = try? await services.supabase.ensureAnonymousSession() {
                await MainActor.run {
                    profile.anonymousUserID = session.userID
                    profile.updatedAt = Date()
                }
            }

            try await services.supabase.upsertProfile(profile)
            await MainActor.run {
                profile.syncStatus = .synced
                try? modelContext.save()
            }
        } catch { }
    }

    private func shouldTriggerDayThreePaywall(for profile: UserProfile) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: profile.createdAt, to: Date()).day ?? 0
        return days >= 3
    }

    private func markPremiumUnlocked() {
        guard let profile else { return }

        let record: SubscriptionRecord
        if let existing = subscriptions.first(where: { $0.userID == profile.id }) {
            record = existing
        } else {
            record = SubscriptionRecord(userID: profile.id)
            modelContext.insert(record)
        }

        record.revenuecatCustomerID = profile.anonymousUserID
        record.entitlement = services.configuration.revenueCatEntitlementID
        record.status = localSubscriptionStatus
        record.updatedAt = Date()
        record.syncStatus = .pending

        try? modelContext.save()
        sync(subscription: record)
        showPaywall = false
    }

    private func sync(subscription: SubscriptionRecord) {
        Task {
            do {
                try await services.supabase.upsertSubscription(subscription)
                await MainActor.run {
                    subscription.syncStatus = .synced
                    try? modelContext.save()
                }
            } catch { }
        }
    }

    private func syncPendingSubscriptions() {
        for subscription in subscriptions where subscription.syncStatus == .pending {
            sync(subscription: subscription)
        }
    }

    private var localSubscriptionStatus: SubscriptionStatus {
        switch services.subscriptions.state {
        case .trial:
            return .trial
        case .active:
            return .active
        case .expired:
            return .expired
        case .unknown, .free, .error:
            return .inactive
        }
    }
}

#Preview {
    if let container = try? ModelContainer(
        for: UserProfile.self, ChatMessage.self, DailyUsage.self,
        WeeklyJournalEntry.self, SubscriptionRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        MainTabView(
            profile: UserProfile(
                name: "Ana",
                dueDate: Calendar.current.date(byAdding: .weekOfYear, value: 14, to: Date()),
                hasCompletedOnboarding: true
            )
        )
        .environment(AppServices())
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "pt_BR"))
    } else {
        Text("Preview indisponível")
    }
}
