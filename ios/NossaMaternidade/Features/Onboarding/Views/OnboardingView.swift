import SwiftData
import SwiftUI

private struct OnboardingChoice {
    let icon: String
    let label: String
    let value: String
}

struct OnboardingView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var name = ""
    @State private var currentMoment: String?
    @State private var selectedPains: Set<String> = []
    @State private var selectedFeelings: Set<String> = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let totalSteps = 5

    // Exact canonical options from nathalia-app (the real product) — memorized source of truth
    private let momentOptions: [OnboardingChoice] = [
        .init(icon: "leaf", label: "Estou grávida", value: "pregnant"),
        .init(icon: "figure.2.and.child.holdinghands", label: "Meu bebê já nasceu", value: "baby_born"),
        .init(icon: "heart", label: "Estou tentando engravidar", value: "trying"),
        .init(icon: "person.2", label: "Quero acompanhar alguém", value: "supporting_someone")
    ]

    // Exact 6 pains from canonical nathalia-app
    private let painOptions: [OnboardingChoice] = [
        .init(icon: "moon", label: "Sono meu ou do bebê", value: "sleep"),
        .init(icon: "cloud.rain", label: "Ansiedade e medo", value: "anxiety"),
        .init(icon: "drop", label: "Amamentação", value: "breastfeeding"),
        .init(icon: "figure.arms.open", label: "Corpo e autoestima", value: "body_self_esteem"),
        .init(icon: "person", label: "Solidão", value: "loneliness"),
        .init(icon: "clock", label: "Rotina sem tempo pra mim", value: "no_time")
    ]

    // Exact 6 desired feelings from canonical nathalia-app
    private let feelingOptions: [OnboardingChoice] = [
        .init(icon: "leaf", label: "Calma", value: "calm"),
        .init(icon: "flame", label: "Força", value: "strength"),
        .init(icon: "star", label: "Confiança", value: "confidence"),
        .init(icon: "sparkles", label: "Conexão", value: "connection"),
        .init(icon: "sun.max", label: "Leveza", value: "lightness"),
        .init(icon: "location.north.line", label: "Direção", value: "direction")
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressBar(current: currentStep, total: totalSteps)
                .padding(.top, AppTheme.Space.x4)

            TabView(selection: $currentStep) {
                WelcomeStep(onContinue: goForward)
                    .tag(0)

                MomentStep(
                    selected: $currentMoment,
                    options: momentOptions,
                    onContinue: goForward
                )
                    .tag(1)

                PainsStep(
                    selected: $selectedPains,
                    options: painOptions,
                    onContinue: goForward
                )
                    .tag(2)

                FeelingsStep(
                    selected: $selectedFeelings,
                    options: feelingOptions,
                    onContinue: goForward
                )
                    .tag(3)

                NameAndSummaryStep(
                    name: $name,
                    currentMoment: currentMoment,
                    pains: selectedPains,
                    feelings: selectedFeelings,
                    isSaving: isSaving,
                    errorMessage: errorMessage,
                    onComplete: completeOnboarding
                )
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: currentStep)
        }
        .premiumScreenBackground()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Onboarding da Nossa Maternidade")
    }

    private func goForward() {
        AppHaptics.light()
        withAnimation {
            currentStep = min(currentStep + 1, totalSteps - 1)
        }
    }

    private func completeOnboarding() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Me diz como posso te chamar."
            AppHaptics.error()
            return
        }

        isSaving = true
        errorMessage = nil

        Task {
            let session = try? await services.supabase.signInAnonymously()
            await MainActor.run {
                saveProfile(name: trimmedName, session: session)
            }
        }
    }

    private func saveProfile(name: String, session: SupabaseSession?) {
        let profile = UserProfile(
            id: UUID().uuidString,
            anonymousUserID: session?.userID ?? UUID().uuidString,
            name: name,
            dueDate: nil,
            isFirstPregnancy: true,
            hasCompletedOnboarding: true,
            syncStatus: session == nil ? .pending : .syncing,
            currentMoment: currentMoment,
            mainPains: Array(selectedPains),
            desiredFeelings: Array(selectedFeelings),
            babyName: nil
        )

        modelContext.insert(profile)
        try? modelContext.save()
        services.subscriptions.configure(appUserID: profile.anonymousUserID)
        AppHaptics.success()
        isSaving = false

        Task {
            await sync(profile)
        }
    }

    private func sync(_ profile: UserProfile) async {
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
        } catch {
            await MainActor.run {
                profile.syncStatus = .pending
                try? modelContext.save()
            }
        }
    }
}

// MARK: - New Rich Steps (using the new components)

private struct WelcomeStep: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepContainer(
            title: "A maternidade não vem com manual.",
            subtitle: "Mas você não precisa viver tudo sozinha."
        ) {
            VStack(spacing: AppTheme.Space.x8) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppTheme.ColorToken.accentPrimary.opacity(0.9))
                    .padding(.vertical, AppTheme.Space.x4)

                Text("Aqui você encontra acolhimento real, ferramentas práticas e uma comunidade que entende.")
                    .font(AppTheme.FontToken.callout)
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Space.x2)
            }

            Spacer()

            PrimaryButton("Começar minha jornada", action: onContinue)
        }
    }
}

private struct MomentStep: View {
    @Binding var selected: String?
    let options: [OnboardingChoice]
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepContainer(
            title: "Em que momento você está?",
            subtitle: "Pra gente cuidar de você do jeito certo."
        ) {
            VStack(spacing: AppTheme.Space.x3) {
                ForEach(options, id: \.value) { choice in
                    OnboardingOptionCard(
                        icon: choice.icon,
                        title: choice.label,
                        isSelected: selected == choice.value,
                        isMultiSelect: false
                    ) {
                        selected = choice.value
                        onContinue()
                    }
                }
            }
        }
    }
}

private struct PainsStep: View {
    @Binding var selected: Set<String>
    let options: [OnboardingChoice]
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepContainer(
            title: "O que mais está pesando hoje?",
            subtitle: "A gente começa por onde dói mais. Pode escolher mais de um."
        ) {
            VStack(spacing: AppTheme.Space.x3) {
                ForEach(options, id: \.value) { choice in
                    OnboardingOptionCard(
                        icon: choice.icon,
                        title: choice.label,
                        isSelected: selected.contains(choice.value),
                        isMultiSelect: true
                    ) {
                        if selected.contains(choice.value) {
                            selected.remove(choice.value)
                        } else {
                            selected.insert(choice.value)
                        }
                    }
                }
            }

            Spacer(minLength: AppTheme.Space.x6)

            PrimaryButton("Continuar", disabled: selected.isEmpty, action: onContinue)
        }
    }
}

private struct FeelingsStep: View {
    @Binding var selected: Set<String>
    let options: [OnboardingChoice]
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepContainer(
            title: "O que você quer sentir nos próximos dias?",
            subtitle: "Como mãe, como mulher, como você. Escolha quantos quiser."
        ) {
            VStack(spacing: AppTheme.Space.x3) {
                ForEach(options, id: \.value) { choice in
                    OnboardingOptionCard(
                        icon: choice.icon,
                        title: choice.label,
                        isSelected: selected.contains(choice.value),
                        isMultiSelect: true
                    ) {
                        if selected.contains(choice.value) {
                            selected.remove(choice.value)
                        } else {
                            selected.insert(choice.value)
                        }
                    }
                }
            }

            Spacer(minLength: AppTheme.Space.x6)

            PrimaryButton("Continuar", disabled: selected.isEmpty, action: onContinue)
        }
    }
}

private struct NameAndSummaryStep: View {
    @Binding var name: String
    let currentMoment: String?
    let pains: Set<String>
    let feelings: Set<String>
    let isSaving: Bool
    let errorMessage: String?
    let onComplete: () -> Void

    var body: some View {
        OnboardingStepContainer(
            title: "Como podemos te chamar?",
            subtitle: nil
        ) {
            VStack(spacing: AppTheme.Space.x6) {
                TextField("Seu nome", text: $name)
                    .textContentType(.givenName)
                    .submitLabel(.done)
                    .font(AppTheme.FontToken.body)
                    .padding(.horizontal, AppTheme.Space.x4)
                    .frame(minHeight: 56)
                    .background(AppTheme.ColorToken.backgroundElevated)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(AppTheme.ColorToken.borderSubtle)
                    )
                    .onSubmit(onComplete)

                if let errorMessage {
                    InlineErrorBanner(message: errorMessage)
                }

                // Mini Summary — emotional preview (tonal cards + reflection)
                if !pains.isEmpty || !feelings.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                        Text("Aqui está o começo do seu cuidado")
                            .font(AppTheme.FontToken.bodyStrong)
                            .foregroundStyle(AppTheme.ColorToken.textPrimary)

                        if !pains.isEmpty {
                            OnboardingSummaryCard(
                                icon: "heart.slash",
                                title: "O que mais pesa",
                                subtitle: pains.joined(separator: " • "),
                                tone: AppTheme.ColorToken.danger
                            )
                        }

                        if !feelings.isEmpty {
                            OnboardingSummaryCard(
                                icon: "sparkles",
                                title: "Como você quer se sentir",
                                subtitle: feelings.joined(separator: " • "),
                                tone: AppTheme.ColorToken.focus
                            )
                        }
                    }
                    .padding(.top, AppTheme.Space.x2)
                }
            }

            Spacer()

            PrimaryButton("Entrar no meu círculo", isLoading: isSaving, action: onComplete)
        }
    }
}

#Preview {
    if let container = try? ModelContainer(
        for: UserProfile.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        OnboardingView()
            .environment(AppServices())
            .modelContainer(container)
            .environment(\.locale, Locale(identifier: "pt_BR"))
    } else {
        Text("Preview indisponível")
    }
}
