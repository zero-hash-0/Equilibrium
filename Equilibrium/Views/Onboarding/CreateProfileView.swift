import SwiftUI

struct CreateProfileView: View {
    @Bindable var vm: OnboardingViewModel
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                nameSection
                goalSection
                stressSection
                Spacer(minLength: 24)
                PrimaryButton(title: "Create Profile") {
                    if vm.validate() { onFinish() }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 48)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Create Profile")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Personalizes your coaching experience")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your Name", systemImage: "person.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.eqMint)

            TextField("e.g. Alex", text: $vm.name)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.white)
                .autocorrectionDisabled()

            if let err = vm.nameError {
                Text(err).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Primary Goal", systemImage: "flag.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.eqMint)

            VStack(spacing: 8) {
                ForEach(PrimaryGoal.allCases, id: \.self) { goal in
                    GoalRow(goal: goal, isSelected: vm.selectedGoal == goal) {
                        vm.selectedGoal = goal
                    }
                }
            }
        }
    }

    private var stressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Baseline Stress Level", systemImage: "waveform.path.ecg")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.eqMint)

            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("How stressed do you typically feel?")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(vm.baselineStress))")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.eqMint)
                    }
                    Slider(value: $vm.baselineStress, in: 1...10, step: 1)
                        .tint(Color.eqMint)
                    HStack {
                        Text("Calm").font(.caption2).foregroundStyle(.secondary)
                        Spacer()
                        Text("Very stressed").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct GoalRow: View {
    let goal: PrimaryGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(goal.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color.eqMint : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
