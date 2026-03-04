import SwiftUI

struct LiquidGlassCard<Content: View>: View {
    var padding: CGFloat = Theme.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Theme.strokeOverlay, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Titled card
struct TitledCard<Accessory: View, Content: View>: View {
    let title: String
    let icon: String
    let accent: Color
    @ViewBuilder let accessory: () -> Accessory
    @ViewBuilder let content: () -> Content

    init(title: String, icon: String, accent: Color = Theme.accentMint,
         @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() },
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title; self.icon = icon; self.accent = accent
        self.accessory = accessory; self.content = content
    }

    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: Theme.sm) {
                HStack {
                    if icon.isEmpty {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(accent)
                    } else {
                        Label(title, systemImage: icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(accent)
                    }
                    Spacer()
                    accessory()
                }
                Divider().background(Theme.strokeOverlay)
                content()
            }
        }
    }
}
