import SwiftUI
import SwiftData

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.xl) {
                headerSection
                nameSection
                goalSection
                stressSection
                Spacer(minLength: Theme.md)
                PrimaryButton(title: "Create Profile") {
                    vm.createProfile(modelContext: modelContext)
                }
            }
            .padding(.horizontal, Theme.xl)
            .padding(.top, 60)
            .padding(.bottom, Theme.xxl)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Create Profile")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text("Tell us a bit about yourself")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            sectionLabel("Your Name", icon: "person.fill")
            TextField("e.g. Alex", text: $vm.name)
                .padding(Theme.md)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(Theme.textPrimary)
                .autocorrectionDisabled()
            if let err = vm.nameError {
                Text(err).font(.caption).foregroundStyle(Theme.destructive)
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            sectionLabel("Primary Goal", icon: "flag.fill")
            VStack(spacing: Theme.xs) {
                ForEach(PrimaryGoal.allCases, id: \.self) { goal in
                    goalRow(goal)
                }
            }
        }
    }

    private func goalRow(_ goal: PrimaryGoal) -> some View {
        let selected = vm.primaryGoal == goal
        return Button { vm.primaryGoal = goal } label: {
            HStack {
                Text(goal.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(selected ? .black : Theme.textPrimary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.black)
                }
            }
            .padding(.horizontal, Theme.md)
            .padding(.vertical, 14)
            .background(selected ? Theme.accentMint : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .animation(.easeInOut(duration: 0.18), value: selected)
    }

    private var stressSection: some View {
        VStack(alignment: .leading, spacing: Theme.xs) {
            sectionLabel("Baseline Stress", icon: "waveform.path.ecg")
            LiquidGlassCard {
                VStack(spacing: Theme.sm) {
                    HStack {
                        Text("How stressed do you usually feel?")
                            .font(.subheadline).foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text("\(Int(vm.baselineStress))")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accentMint)
                    }
                    Slider(value: $vm.baselineStress, in: 1...10, step: 1).tint(Theme.accentMint)
                    HStack {
                        Text("Calm").font(.caption2).foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text("Very Stressed").font(.caption2).foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
    }

    private func sectionLabel(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.accentMint)
    }
}
