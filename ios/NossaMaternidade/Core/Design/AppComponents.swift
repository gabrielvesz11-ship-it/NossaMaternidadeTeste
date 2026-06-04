import SwiftUI

struct PremiumCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.Space.x4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.ColorToken.backgroundElevated)
            .clipShape(.rect(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.ColorToken.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: AppTheme.Shadow.cardColor,
                radius: AppTheme.Shadow.cardRadius,
                x: 0,
                y: AppTheme.Shadow.cardY
            )
    }
}

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let disabled: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Space.x2) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.small)
                }

                Text(title)
                    .font(AppTheme.FontToken.bodyStrong)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(disabled ? AppTheme.ColorToken.borderSubtle : AppTheme.ColorToken.accentPrimary)
            .clipShape(.rect(cornerRadius: AppTheme.Radius.button))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .scaleEffect(isLoading ? 0.99 : 1)
        .animation(.spring(response: 0.26, dampingFraction: 0.84), value: isLoading)
    }
}

struct SecondaryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.FontToken.callout.weight(.semibold))
                .foregroundStyle(isSelected ? .white : AppTheme.ColorToken.textPrimary)
                .padding(.horizontal, AppTheme.Space.x4)
                .padding(.vertical, AppTheme.Space.x3)
                .background(isSelected ? AppTheme.ColorToken.accentPrimary : AppTheme.ColorToken.backgroundElevated)
                .clipShape(.capsule)
                .overlay(
                    Capsule()
                        .stroke(AppTheme.ColorToken.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct InlineErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(AppTheme.FontToken.callout)
            .foregroundStyle(AppTheme.ColorToken.textPrimary)
            .padding(AppTheme.Space.x3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.ColorToken.warning.opacity(0.14))
            .clipShape(.rect(cornerRadius: AppTheme.Radius.card))
            .accessibilityLabel(message)
    }
}

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppTheme.ColorToken.backgroundPrimary.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func premiumScreenBackground() -> some View {
        modifier(ScreenBackground())
    }
}
