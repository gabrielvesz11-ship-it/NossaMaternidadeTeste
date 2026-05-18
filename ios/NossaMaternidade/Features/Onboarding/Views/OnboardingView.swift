import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var name = ""
    @State private var selectedStage: MaternalStage = .pregnant
    @State private var babyName = ""
    @State private var dueDate: Date = Date()
    @State private var babyBirthDate: Date = Date()
    @State private var hasCompleted = false
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                progressBar
                
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    nameStep.tag(1)
                    stageStep.tag(2)
                    detailStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tela de boas-vindas")
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.primaryLight.opacity(0.3))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.primary)
            }
            
            VStack(spacing: 16) {
                Text("Nossa Maternidade")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Um espaço seguro para cada momento da sua jornada materna. Estamos juntas.")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Button(action: {
                AppHaptics.medium()
                withAnimation {
                    currentStep = 1
                }
            }) {
                Text("Começar")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.primary)
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .accessibilityLabel("Botão começar")
            .accessibilityHint("Avança para o próximo passo do cadastro")
        }
    }
    
    private var nameStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Como posso te chamar?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            TextField("Seu nome ou apelido", text: $name)
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(AppColors.backgroundSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 32)
                .accessibilityLabel("Campo para digitar seu nome")
            
            Spacer()
            
            Button(action: {
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                    AppHaptics.error()
                    return
                }
                AppHaptics.medium()
                withAnimation {
                    currentStep = 2
                }
            }) {
                Text("Continuar")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(name.isEmpty ? AppColors.textTertiary : AppColors.primary)
                    .clipShape(.rect(cornerRadius: 16))
                    .animation(.easeInOut, value: name.isEmpty)
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private var stageStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Em qual momento você está?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Vou personalizar sua experiência com base nisso.")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(MaternalStage.allCases, id: \.self) { stage in
                        stageCard(stage)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    private func stageCard(_ stage: MaternalStage) -> some View {
        Button(action: {
            AppHaptics.selection()
            selectedStage = stage
            withAnimation {
                currentStep = 3
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: stage.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text(stage.onboardingPrompt)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(AppColors.backgroundElevated)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("Etapa \(stage.displayName)")
        .accessibilityHint(stage.onboardingPrompt)
    }
    
    private var detailStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Últimos detalhes")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 32)
            
            ScrollView {
                VStack(spacing: 20) {
                    if selectedStage == .pregnant || selectedStage == .tryingToConceive {
                        dateField(
                            title: selectedStage == .pregnant ? "Data prevista do parto" : "Início do ciclo atual",
                            date: $dueDate
                        )
                    }
                    
                    if selectedStage == .newborn || selectedStage == .infant || selectedStage == .toddler {
                        TextField("Nome do bebê (opcional)", text: $babyName)
                            .font(.system(size: 17))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(AppColors.backgroundSecondary)
                            .clipShape(.rect(cornerRadius: 12))
                            .padding(.horizontal, 24)
                        
                        dateField(
                            title: "Data de nascimento",
                            date: $babyBirthDate
                        )
                    }
                }
                .padding(.top, 16)
            }
            
            Spacer()
            
            Button(action: {
                AppHaptics.success()
                completeOnboarding()
            }) {
                Text("Entrar na comunidade")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.primary)
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private func dateField(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 24)
            
            DatePicker(
                title,
                selection: date,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(AppColors.backgroundSecondary)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 24)
            .accessibilityLabel(title)
        }
    }
    
    private func completeOnboarding() {
        let profile = UserProfile(
            name: name,
            stage: selectedStage,
            babyName: babyName.isEmpty ? nil : babyName,
            babyBirthDate: (selectedStage == .newborn || selectedStage == .infant || selectedStage == .toddler) ? babyBirthDate : nil,
            dueDate: (selectedStage == .pregnant || selectedStage == .tryingToConceive) ? dueDate : nil,
            hasCompletedOnboarding: true
        )
        modelContext.insert(profile)
        hasCompleted = true
    }
}
