import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var isReady = false
    
    var hasCompletedOnboarding: Bool {
        profiles.first?.hasCompletedOnboarding ?? false
    }
    
    var body: some View {
        ZStack {
            if !isReady {
                SplashView()
            } else if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeInOut(duration: 0.4)) {
                isReady = true
            }
        }
    }
}

struct SplashView: View {
    @State private var scale = 0.8
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryLight.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(AppColors.primary)
                }
                
                Text("Nossa Maternidade")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Estamos juntas")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
