import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.eqMint.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.eqMint)
            }
            .padding(.bottom, 36)

            Text("Equilibrium")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("AI Financial Wellness Coach")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.eqMint)
                .padding(.top, 6)

            Spacer().frame(height: 48)

            VStack(spacing: 20) {
                FeatureRow(icon: "calendar.badge.checkmark", title: "Daily Check-Ins",
                           subtitle: "Track stress, sleep, and spending urges")
                FeatureRow(icon: "sparkles", title: "AI Insights",
                           subtitle: "Personalized coaching after every check-in")
                FeatureRow(icon: "chart.xyaxis.line", title: "Wellness Trends",
                           subtitle: "See your financial health improve over time")
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: "Get Started") { onNext() }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.eqMint)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
