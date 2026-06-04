import SwiftUI

struct HomeView: View {
    let profile: UserProfile?
    let openNathIA: () -> Void

    private var pregnancyWeek: Int? {
        PregnancyCalculator.currentWeek(dueDate: profile?.dueDate)
    }

    private var greeting: String {
        let name = profile?.name.isEmpty == false ? profile?.name ?? "mãe" : "mãe"
        guard let pregnancyWeek else {
            return "\(dayGreeting), \(name). Que bom te ver por aqui."
        }

        return "\(dayGreeting), \(name). Semana \(pregnancyWeek) de gestação."
    }

    private var dayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bom dia"
        case 12..<18: return "Boa tarde"
        default: return "Boa noite"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Space.x6) {
                    HomeHeader(greeting: greeting)

                    VStack(spacing: AppTheme.Space.x4) {
                        HomeCareCard(
                            title: "Seu bebê hoje",
                            text: PregnancyCalculator.babySizeText(for: pregnancyWeek),
                            symbolName: "circle.hexagongrid.fill",
                            tint: AppTheme.ColorToken.accentSecondary
                        )

                        HomeCareCard(
                            title: "Um cuidado pequeno",
                            text: DailySuggestion.text(),
                            symbolName: "drop.fill",
                            tint: AppTheme.ColorToken.accentPrimary
                        )

                        NathIAHomeCard(openNathIA: openNathIA)
                    }

                    PregnancyProgressRing(week: pregnancyWeek, progress: PregnancyCalculator.progress(dueDate: profile?.dueDate))
                        .padding(.top, AppTheme.Space.x2)
                }
                .padding(.horizontal, AppTheme.Space.x6)
                .padding(.vertical, AppTheme.Space.x8)
            }
            .premiumScreenBackground()
            .navigationTitle("Círculo de Cuidado")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct HomeHeader: View {
    let greeting: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
            Text("Círculo de Cuidado")
                .font(AppTheme.FontToken.caption)
                .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                .textCase(.uppercase)

            Text(greeting)
                .font(AppTheme.FontToken.display)
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct HomeCareCard: View {
    let title: String
    let text: String
    let symbolName: String
    let tint: Color

    var body: some View {
        PremiumCard {
            HStack(alignment: .top, spacing: AppTheme.Space.x4) {
                Image(systemName: symbolName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14))
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Space.x2) {
                    Text(title)
                        .font(AppTheme.FontToken.caption)
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)

                    Text(text)
                        .font(AppTheme.FontToken.body)
                        .foregroundStyle(AppTheme.ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct NathIAHomeCard: View {
    let openNathIA: () -> Void

    var body: some View {
        Button(action: openNathIA) {
            PremiumCard {
                HStack(alignment: .center, spacing: AppTheme.Space.x4) {
                    VStack(alignment: .leading, spacing: AppTheme.Space.x2) {
                        Text("Conversa com a NathIA →")
                            .font(AppTheme.FontToken.bodyStrong)
                            .foregroundStyle(AppTheme.ColorToken.textPrimary)

                        Text("Tem alguma dúvida ou só quer desabafar?")
                            .font(AppTheme.FontToken.callout)
                            .foregroundStyle(AppTheme.ColorToken.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: AppTheme.Space.x3)

                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Conversa com a NathIA. Tem alguma dúvida ou só quer desabafar?")
    }
}

private struct PregnancyProgressRing: View {
    let week: Int?
    let progress: Double

    var body: some View {
        PremiumCard {
            HStack(spacing: AppTheme.Space.x4) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.ColorToken.borderSubtle, lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AppTheme.ColorToken.accentSecondary,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text(week.map { "\($0)" } ?? "—")
                        .font(AppTheme.FontToken.section)
                        .foregroundStyle(AppTheme.ColorToken.textPrimary)
                }
                .frame(width: 84, height: 84)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Space.x2) {
                    Text("Sua jornada")
                        .font(AppTheme.FontToken.caption)
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)

                    Text(week.map { "Semana \($0) de 40" } ?? "Vamos acompanhar no seu tempo.")
                        .font(AppTheme.FontToken.body)
                        .foregroundStyle(AppTheme.ColorToken.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(week.map { "Semana \($0) de 40" } ?? "Progresso da gestação indisponível")
    }
}

#Preview {
    HomeView(
        profile: UserProfile(
            name: "Ana",
            dueDate: Calendar.current.date(byAdding: .weekOfYear, value: 14, to: Date()),
            hasCompletedOnboarding: true
        ),
        openNathIA: {}
    )
    .environment(\.locale, Locale(identifier: "pt_BR"))}
