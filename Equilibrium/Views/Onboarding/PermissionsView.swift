import SwiftUI
import UserNotifications

struct PermissionsView: View {
    let onNext: () -> Void
    @State private var requested = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.eqMint)
                .padding(.bottom, 28)

            Text("Stay on Track")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Enable notifications for daily check-in reminders. You can change this anytime in Settings.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 36)
                .padding(.top, 12)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(title: "Enable Notifications") {
                    requestNotifications()
                }

                Button("Skip for now") { onNext() }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async { onNext() }
        }
    }
}
