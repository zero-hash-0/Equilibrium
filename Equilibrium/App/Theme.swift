import SwiftUI

enum Theme {
    // MARK: - Spacing
    static let xs: CGFloat  = 8
    static let sm: CGFloat  = 12
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 20
    static let xl: CGFloat  = 24
    static let xxl: CGFloat = 32

    // MARK: - Corner radius
    static let cornerRadius: CGFloat = 20
    static let pillRadius: CGFloat   = 50

    // MARK: - Icon sizes
    static let iconSM: CGFloat = 18
    static let iconMD: CGFloat = 24
    static let iconLG: CGFloat = 36
    static let iconXL: CGFloat = 52

    // MARK: - Semantic colours
    static let accentMint  = Color(red: 0.44, green: 0.85, blue: 0.78)
    static let accentCyan  = Color(red: 0.35, green: 0.78, blue: 0.90)
    static let background  = Color(red: 0.10, green: 0.11, blue: 0.14)
    static let surface     = Color(red: 0.15, green: 0.17, blue: 0.22)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.60)
    static let strokeOverlay = Color.white.opacity(0.10)
    static let destructive = Color(red: 1.0, green: 0.35, blue: 0.35)

    // MARK: - Gradient
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentMint, accentCyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - View extension helpers
extension View {
    func eqBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
