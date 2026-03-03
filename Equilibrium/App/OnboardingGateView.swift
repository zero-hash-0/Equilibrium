import SwiftUI
import SwiftData

struct OnboardingGateView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            OnboardingStack()
        } else {
            MainTabView()
        }
    }
}

private struct OnboardingStack: View {
    @State private var step: OnboardingStep = .welcome

    enum OnboardingStep {
        case welcome, permissions, createProfile
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            switch step {
            case .welcome:
                WelcomeView(onContinue: { step = .permissions })
            case .permissions:
                PermissionsView(onContinue: { step = .createProfile })
            case .createProfile:
                CreateProfileView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }
}
