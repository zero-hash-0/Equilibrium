import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var context
    @State private var step: Int = 0
    @State private var vm = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            switch step {
            case 0: WelcomeView(onNext: { step = 1 })
            case 1: PermissionsView(onNext: { step = 2 })
            case 2: CreateProfileView(vm: vm, onFinish: {
                vm.saveProfile(context: context)
                onComplete()
            })
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.eqGraphite, Color.eqSlate.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
