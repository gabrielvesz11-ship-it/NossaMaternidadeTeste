import SwiftUI

struct PaywallView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.openURL) private var openURL
    let onUnlocked: () -> Void
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Space.x6) {
                PaywallHero()

                VStack(spacing: AppTheme.Space.x3) {
                    ForEach(PaywallBenefit.allCases) { benefit in
                        PaywallBenefitRow(benefit: benefit)
                    }
                }

                VStack(spacing: AppTheme.Space.x3) {
                    PrimaryButton(
                        "Começar 7 dias grátis",
                        isLoading: services.subscriptions.isLoading,
                        action: purchase
                    )

                    if let errorMessage {
                        InlineErrorBanner(message: errorMessage)
                    }
                }

                PaywallFooter(
                    restore: restore,
                    terms: openTerms,
                    privacy: openPrivacy
                )
            }
            .padding(.horizontal, AppTheme.Space.x6)
            .padding(.top, AppTheme.Space.x8)
            .padding(.bottom, AppTheme.Space.x8)
        }
        .premiumScreenBackground()
        .accessibilityElement(children: .contain)
    }

    private func purchase() {
        errorMessage = nil
        Task {
            do {
                try await services.subscriptions.purchaseYearly()
                if services.subscriptions.isPremium {
                    await MainActor.run {
                        AppHaptics.success()
                        onUnlocked()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = warmError(from: error)
                    AppHaptics.error()
                }
            }
        }
    }

    private func restore() {
        errorMessage = nil
        Task {
            do {
                try await services.subscriptions.restorePurchases()
                await MainActor.run {
                    if services.subscriptions.isPremium {
                        onUnlocked()
                    } else {
                        errorMessage = "Não encontrei uma assinatura ativa nessa conta."
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = warmError(from: error)
                }
            }
        }
    }

    private func warmError(from error: Error) -> String {
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            return description
        }
        return "Não deu para concluir agora. Tenta de novo com calma daqui a pouco."
    }

    private func openTerms() {
        openURL(services.configuration.termsURL)
    }

    private func openPrivacy() {
        openURL(services.configuration.privacyURL)
    }
}

private struct PaywallHero: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Space.x4) {
            Text("Nossa Maternidade")
                .font(AppTheme.FontToken.caption)
                .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                Text("Continue sendo cuidada todos os dias")
                    .font(AppTheme.FontToken.display)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Desbloqueie a NathIA sem limites e registre sua jornada com mais carinho.")
                    .font(AppTheme.FontToken.body)
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            PremiumCard {
                HStack(spacing: AppTheme.Space.x4) {
                    VStack(alignment: .leading, spacing: AppTheme.Space.x1) {
                        Text("R$ 89,90/ano")
                            .font(AppTheme.FontToken.section)
                            .foregroundStyle(AppTheme.ColorToken.textPrimary)

                        Text("7 dias grátis")
                            .font(AppTheme.FontToken.callout)
                            .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

private enum PaywallBenefit: String, CaseIterable, Identifiable {
    case nathIA = "NathIA sem limites"
    case diary = "Diário com fotos ilimitado"
    case nathalia = "Conteúdo semanal da Nathália"

    var id: String { rawValue }
}

private struct PaywallBenefitRow: View {
    let benefit: PaywallBenefit

    var body: some View {
        HStack(spacing: AppTheme.Space.x3) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .frame(width: 24, height: 24)
                .background(AppTheme.ColorToken.accentSecondary.opacity(0.32))
                .clipShape(.circle)
                .accessibilityHidden(true)

            Text(benefit.rawValue)
                .font(AppTheme.FontToken.bodyStrong)
                .foregroundStyle(AppTheme.ColorToken.textPrimary)

            Spacer()
        }
        .padding(.vertical, AppTheme.Space.x2)
        .accessibilityElement(children: .combine)
    }
}

private struct PaywallFooter: View {
    let restore: () -> Void
    let terms: () -> Void
    let privacy: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Space.x4) {
            Button("Restaurar compra", action: restore)
            Button("Termos", action: terms)
            Button("Privacidade", action: privacy)
        }
        .font(AppTheme.FontToken.caption)
        .foregroundStyle(AppTheme.ColorToken.textSecondary)
        .frame(maxWidth: .infinity)
        .padding(.top, AppTheme.Space.x2)
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView(onUnlocked: {})
        .environment(AppServices())
        .environment(\.locale, Locale(identifier: "pt_BR"))}
