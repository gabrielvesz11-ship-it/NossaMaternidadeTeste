import SwiftUI

enum AppTheme {
    enum ColorToken {
        static let backgroundPrimary = Color(hex: "F7F1E8")
        static let backgroundElevated = Color(hex: "FFFFFF")
        static let accentPrimary = Color(hex: "C76B4A")
        static let accentSecondary = Color(hex: "A8B89A")
        static let textPrimary = Color(hex: "3D2E26")
        static let textSecondary = Color(hex: "3D2E26").opacity(0.60)
        static let borderSubtle = Color(hex: "3D2E26").opacity(0.12)
        static let danger = Color(hex: "B84B42")
        static let warning = Color(hex: "B7803D")
        static let focus = Color(hex: "6A7E62")
    }

    enum FontToken {
        static let display = Font.system(.largeTitle, design: .serif, weight: .semibold)
        static let title = Font.system(.title2, design: .serif, weight: .semibold)
        static let section = Font.system(.title3, design: .serif, weight: .semibold)
        static let body = Font.system(.body, design: .default, weight: .regular)
        static let bodyStrong = Font.system(.body, design: .default, weight: .semibold)
        static let callout = Font.system(.callout, design: .default, weight: .regular)
        static let caption = Font.system(.caption, design: .default, weight: .medium)
    }

    enum Space {
        static let x1: CGFloat = 4
        static let x2: CGFloat = 8
        static let x3: CGFloat = 12
        static let x4: CGFloat = 16
        static let x6: CGFloat = 24
        static let x8: CGFloat = 32
        static let x12: CGFloat = 48
    }

    enum Radius {
        static let card: CGFloat = 12
        static let sheet: CGFloat = 20
        static let button: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let cardColor = Color(hex: "3D2E26").opacity(0.06)
        static let cardRadius: CGFloat = 18
        static let cardY: CGFloat = 8
    }
}

enum AppColors {
    static let primary = AppTheme.ColorToken.accentPrimary
    static let primaryLight = AppTheme.ColorToken.accentPrimary.opacity(0.18)
    static let primaryDark = Color(hex: "9F4E35")
    static let background = AppTheme.ColorToken.backgroundPrimary
    static let backgroundSecondary = Color(hex: "EFE5D8")
    static let backgroundElevated = AppTheme.ColorToken.backgroundElevated
    static let accent = AppTheme.ColorToken.accentSecondary
    static let accentLight = AppTheme.ColorToken.accentSecondary.opacity(0.22)
    static let textPrimary = AppTheme.ColorToken.textPrimary
    static let textSecondary = AppTheme.ColorToken.textSecondary
    static let textTertiary = AppTheme.ColorToken.textPrimary.opacity(0.42)
    static let danger = AppTheme.ColorToken.danger
    static let success = AppTheme.ColorToken.accentSecondary
    static let warning = AppTheme.ColorToken.warning
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64

        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
