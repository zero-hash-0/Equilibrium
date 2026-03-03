import SwiftUI

// MARK: - Color Palette
extension Color {
    static let eqBackground  = Color("EQBackground")
    static let eqAccent      = Color("EQAccent")
    static let eqSurface     = Color("EQSurface")
    static let eqText        = Color("EQText")
    static let eqSubtext     = Color("EQSubtext")

    // Fallbacks if asset catalog colors not defined
    static let eqMint        = Color(red: 0.44, green: 0.85, blue: 0.78)
    static let eqSlate       = Color(red: 0.18, green: 0.20, blue: 0.25)
    static let eqGraphite    = Color(red: 0.13, green: 0.14, blue: 0.18)
}

// MARK: - Date helpers
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var shortFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }
}

// MARK: - View modifiers
extension View {
    func glassCard(cornerRadius: CGFloat = 18) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}
