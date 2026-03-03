import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]
    @State private var onboardingComplete = false

    var body: some View {
        Group {
            if profiles.isEmpty && !onboardingComplete {
                OnboardingFlowView(onComplete: { onboardingComplete = true })
            } else {
                MainTabView()
            }
        }
        .onChange(of: profiles.count) { _, count in
            if count > 0 { onboardingComplete = true }
        }
    }
}
