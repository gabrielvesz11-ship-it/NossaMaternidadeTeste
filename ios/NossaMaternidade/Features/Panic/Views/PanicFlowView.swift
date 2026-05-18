import SwiftUI

struct PanicFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showNossaLuz = false
    @State private var showBreathing = false
    @State private var showCommunity = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.nightBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if currentStep == 0 {
                        validateStep
                    } else if currentStep == 1 {
                        calmStep
                    } else if currentStep == 2 {
                        actionsStep
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        AppHaptics.light()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.nightText)
                }
            }
        }
        .sheet(isPresented: $showNossaLuz) {
            NossaLuzView()
        }
    }
    
    private var validateStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.danger.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.danger)
                }
                
                Text("Estou aqui com você.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.nightText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Respira. Você não está sozinha. Milhares de mães passam exatamente por isso agora.")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.nightText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    AppHaptics.medium()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        currentStep = 1
                    }
                }) {
                    Text("Estou me sentindo melhor")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.success)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .accessibilityLabel("Estou me sentindo melhor")
                
                Button(action: {
                    AppHaptics.panic()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        currentStep = 1
                    }
                }) {
                    Text("Ainda preciso de ajuda")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.danger)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .accessibilityLabel("Ainda preciso de ajuda")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private var calmStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Vamos respirar juntas.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.nightText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            BreathingAnimation()
                .frame(height: 200)
            
            Text("Inspire profundamente pelo nariz.\nSegure.\nExpire pela boca.")
                .font(.system(size: 17))
                .foregroundStyle(AppColors.nightText.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                AppHaptics.medium()
                withAnimation {
                    currentStep = 2
                }
            }) {
                Text("Próximo")
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
    
    private var actionsStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("O que você precisa agora?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.nightText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                PanicActionCard(
                    icon: "music.note",
                    title: "Nossa Luz",
                    subtitle: "Sons calmantes para acalmar o momento",
                    color: AppColors.primary
                ) {
                    AppHaptics.success()
                    showNossaLuz = true
                }
                
                PanicActionCard(
                    icon: "heart.text.square",
                    title: "Falar com a comunidade",
                    subtitle: "Mães acordadas agora, prontas para te ouvir",
                    color: AppColors.accent
                ) {
                    AppHaptics.medium()
                    dismiss()
                }
                
                PanicActionCard(
                    icon: "book.closed",
                    title: "Escrever no diário",
                    subtitle: "Coloque o que sente no papel. Alivia.",
                    color: AppColors.primaryLight
                ) {
                    AppHaptics.medium()
                    dismiss()
                }
                
                PanicActionCard(
                    icon: "phone.fill",
                    title: "Contato de emergência",
                    subtitle: "Se sentir que não consegue, ligue para alguém",
                    color: AppColors.warning
                ) {
                    AppHaptics.heavy()
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

struct BreathingAnimation: View {
    @State private var scale = 1.0
    @State private var opacity = 0.6
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .fill(AppColors.primaryLight.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .scaleEffect(scale + CGFloat(i) * 0.15)
                    .opacity(opacity - Double(i) * 0.15)
            }
            
            Circle()
                .fill(AppColors.primary)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("Respire")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                scale = 1.4
                opacity = 0.3
            }
        }
    }
}

struct PanicActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.2))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.nightText)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.nightText.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.nightText.opacity(0.4))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(AppColors.nightSurface)
            .clipShape(.rect(cornerRadius: 16))
        }
        .accessibilityLabel("\(title). \(subtitle)")
    }
}
