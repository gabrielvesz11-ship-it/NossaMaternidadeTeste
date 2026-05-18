import SwiftUI

enum AppColors {
    static let primary = Color(hex: "C2705A")
    static let primaryLight = Color(hex: "D9A08B")
    static let primaryDark = Color(hex: "A05A48")
    
    static let background = Color(hex: "FDF8F5")
    static let backgroundSecondary = Color(hex: "F5EDE8")
    static let backgroundElevated = Color(hex: "FFFFFF")
    
    static let accent = Color(hex: "8FA68E")
    static let accentLight = Color(hex: "B8C9B7")
    
    static let textPrimary = Color(hex: "3D3532")
    static let textSecondary = Color(hex: "7A6E6A")
    static let textTertiary = Color(hex: "A89E9A")
    
    static let nightBackground = Color(hex: "1C1917")
    static let nightSurface = Color(hex: "2A2624")
    static let nightText = Color(hex: "E8E0DB")
    
    static let danger = Color(hex: "C75B5B")
    static let success = Color(hex: "6B9E75")
    static let warning = Color(hex: "D4A656")
    
    static let calmGradient = LinearGradient(
        colors: [
            Color(hex: "2A2624"),
            Color(hex: "1C1917"),
            Color(hex: "3D3532")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
