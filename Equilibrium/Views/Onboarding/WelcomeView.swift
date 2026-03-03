import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            iconSection
            Spacer().frame(height: Theme.xxl)
            textSection
            Spacer()
            bottomSection
        }
        .padding(.horizontal, Theme.xl)
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(Theme.accentMint.opacity(0.12))
                .frame(width: 130, height: 130)
            Image(systemName: "brain.head.profile")
                .font(.system(size: 56))
                .foregroundStyle(Theme.accentMint)
        }
    }

    private var textSection: some View {
        VStack(spacing: Theme.sm) {
            Text("Equilibrium")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text("Daily check-ins + AI insights")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.accentMint)
            Spacer().frame(height: Theme.lg)
            VStack(spacing: Theme.sm) {
                featureRow(icon: "calendar.badge.checkmark", text: "Track stress, sleep & spending urges")
                featureRow(icon: "sparkles", text: "Personalized AI coaching after each check-in")
                featureRow(icon: "chart.line.uptrend.xyaxis", text: "Visualize your wellness trends over time")
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.accentMint)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
    }

    private var bottomSection: some View {
        VStack(spacing: Theme.sm) {
            PrimaryButton(title: "Get Started", action: onContinue)
        }
        .padding(.bottom, Theme.xxl)
    }
}
