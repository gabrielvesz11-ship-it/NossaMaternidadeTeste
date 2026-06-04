import SwiftUI

// MARK: - Onboarding Option Card (inspired by best patterns, native premium)
struct OnboardingOptionCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let isMultiSelect: Bool
    let action: () -> Void

    var body: some View {
        Button {
            AppHaptics.selection()
            action()
        } label: {
            HStack(spacing: AppTheme.Space.x4) {
                // Icon inside colored circle — signature visual from canonical images
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? Color.white.opacity(0.22)
                              : AppTheme.ColorToken.accentPrimary.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : AppTheme.ColorToken.accentPrimary)
                }

                Text(title)
                    .font(AppTheme.FontToken.bodyStrong)
                    .foregroundStyle(isSelected ? .white : AppTheme.ColorToken.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: isMultiSelect ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
            }
            .padding(.horizontal, AppTheme.Space.x4)
            .padding(.vertical, AppTheme.Space.x4)
            .background(
                isSelected
                    ? AppTheme.ColorToken.accentPrimary
                    : AppTheme.ColorToken.backgroundElevated
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(
                        isSelected ? Color.clear : AppTheme.ColorToken.borderSubtle,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: AppTheme.Shadow.cardColor,
                radius: isSelected ? 0 : AppTheme.Shadow.cardRadius,
                x: 0,
                y: isSelected ? 0 : AppTheme.Shadow.cardY
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Summary Card with tonal personality (coral/sage/lavender style using warm palette)
struct OnboardingSummaryCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tone: Color

    var body: some View {
        HStack(spacing: AppTheme.Space.x4) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tone)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.FontToken.bodyStrong)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                Text(subtitle)
                    .font(AppTheme.FontToken.callout)
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
            }

            Spacer()
        }
        .padding(AppTheme.Space.x4)
        .background(
            // Subtle tonal wash so the card reflects the emotional choice
            tone.opacity(0.08)
        )
        .overlay(
            // Left accent bar for visual distinction (terracota / sage / warm tones)
            HStack {
                Rectangle()
                    .fill(tone)
                    .frame(width: 4)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.ColorToken.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Progress with caring avatar presence (inspired by canonical images)
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: AppTheme.Space.x2) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.ColorToken.borderSubtle)
                        .frame(height: 4)

                    Capsule()
                        .fill(AppTheme.ColorToken.accentPrimary)
                        .frame(width: geo.size.width * CGFloat(current + 1) / CGFloat(total), height: 4)
                }
            }
            .frame(height: 4)

            // Small avatar presence — "Nathia está aqui com você" (emotional companionship)
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(AppTheme.ColorToken.accentPrimary.opacity(0.15))
                        .frame(width: 18, height: 18)
                    Image(systemName: "heart.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                }
                Text("Nathia com você")
                    .font(AppTheme.FontToken.caption)
                    .foregroundStyle(AppTheme.ColorToken.textSecondary.opacity(0.85))
            }
        }
        .padding(.horizontal, AppTheme.Space.x6)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: current)
    }
}

// MARK: - Onboarding Step Container (evolved from existing shell)
struct OnboardingStepContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Space.x6) {
            VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                Text(title)
                    .font(AppTheme.FontToken.display)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTheme.FontToken.callout)
                        .foregroundStyle(AppTheme.ColorToken.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
        }
        .padding(.horizontal, AppTheme.Space.x6)
    }
}
