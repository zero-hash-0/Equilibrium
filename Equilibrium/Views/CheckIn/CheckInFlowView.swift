import SwiftUI
import SwiftData

struct CheckInFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @State private var vm = CheckInViewModel()
    @State private var navigateToCoach = false
    @State private var savedCheckIn: CheckIn? = nil

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    navBar
                    ProgressView(value: vm.progress)
                        .tint(Theme.accentMint)
                        .padding(.horizontal, Theme.lg)
                        .padding(.bottom, Theme.md)
                    stepContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .navigationDestination(isPresented: $navigateToCoach) {
                if let ci = savedCheckIn, let p = profile {
                    AICoachView(checkIn: ci, profile: p, onDone: { dismiss() })
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: vm.step)
    }

    private var navBar: some View {
        HStack {
            Button {
                if vm.canGoBack { vm.prevStep() } else { dismiss() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.accentMint)
            }
            Spacer()
            Text("Step \(vm.step) of \(vm.totalSteps)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Button("Cancel") { dismiss() }
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, Theme.lg)
        .padding(.top, Theme.md)
        .padding(.bottom, Theme.sm)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case 1: Step1StressView(vm: vm)
        case 2: Step2UrgeView(vm: vm)
        case 3: Step3SleepView(vm: vm)
        case 4: Step4GoalView(vm: vm) {
            vm.nextStep()
        }
        case 5: Step5MoneyTriggersView(vm: vm) {
            let ci = vm.submit(modelContext: modelContext)
            savedCheckIn = ci
            navigateToCoach = true
        }
        default: EmptyView()
        }
    }
}
