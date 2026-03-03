import SwiftUI

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.ultraThinMaterial)
            .foregroundStyle(destructive ? Theme.destructive : Theme.accentMint)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(destructive ? Theme.destructive.opacity(0.5) : Theme.strokeOverlay, lineWidth: 1)
            )
        }
    }
}
