import SwiftUI
import UserNotifications

struct PermissionsView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accentMint)
            Spacer().frame(height: Theme.xl)
            Text("Stay on Track")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Spacer().frame(height: Theme.sm)
            Text("Get a daily reminder to complete your check-in. You can change this any time in Settings.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: Theme.sm) {
                PrimaryButton(title: "Enable Notifications") {
                    requestNotifications()
                }
                SecondaryButton(title: "Not Now", action: onContinue)
            }
            .padding(.bottom, Theme.xxl)
        }
        .padding(.horizontal, Theme.xl)
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                DispatchQueue.main.async { onContinue() }
            }
    }
}
