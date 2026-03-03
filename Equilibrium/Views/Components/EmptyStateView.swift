import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: Theme.md) {
            Image(systemName: icon)
                .font(.system(size: Theme.iconXL))
                .foregroundStyle(Theme.accentMint.opacity(0.5))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.xl)
        .frame(maxWidth: .infinity)
    }
}
