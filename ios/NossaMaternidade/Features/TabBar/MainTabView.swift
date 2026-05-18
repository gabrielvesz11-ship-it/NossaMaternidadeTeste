import SwiftUI

struct MainTabView: View {
    @State private var router = AppRouter()
    @State private var showPanic = false
    @State private var showNossaLuz = false
    
    var body: some View {
        ZStack {
            TabView(selection: $router.selectedTab) {
                CommunityView()
                    .tabItem {
                        Label(AppRouter.Tab.community.title, systemImage: AppRouter.Tab.community.icon)
                    }
                    .tag(AppRouter.Tab.community)
                
                TrackerView()
                    .tabItem {
                        Label(AppRouter.Tab.tracker.title, systemImage: AppRouter.Tab.tracker.icon)
                    }
                    .tag(AppRouter.Tab.tracker)
                
                JournalView()
                    .tabItem {
                        Label(AppRouter.Tab.journal.title, systemImage: AppRouter.Tab.journal.icon)
                    }
                    .tag(AppRouter.Tab.journal)
            }
            .tint(AppColors.primary)
            
            VStack {
                Spacer()
                panicButton
            }
            .padding(.bottom, 90)
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $showPanic) {
            PanicFlowView()
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showNossaLuz) {
            NossaLuzView()
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
        }
    }
    
    private var panicButton: some View {
        Button(action: {
            AppHaptics.panic()
            showPanic = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 18))
                Text("Preciso de ajuda")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppColors.danger)
            .clipShape(.rect(cornerRadius: 28))
            .shadow(color: AppColors.danger.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel("Botão de emergência emocional")
        .accessibilityHint("Abre ferramentas de acalma para momentos difíceis")
    }
}
