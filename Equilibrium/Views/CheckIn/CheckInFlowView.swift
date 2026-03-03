import SwiftUI
import SwiftData

struct CheckInFlowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @State private var vm = CheckInViewModel()
    @State private var navigateToCoach = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.eqGraphite, Color.eqSlate],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            if vm.currentStep > 1 { vm.previousStep() }
                            else { dismiss() }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.eqMint)
                        }
                        Spacer()
                        Text("Step \(vm.currentStep) of \(vm.totalSteps)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    StepProgressBar(current: vm.currentStep, total: vm.totalSteps)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    // Step content
                    Group {
                        switch vm.currentStep {
                        case 1: StepStressView(stressLevel: $vm.stressLevel, onNext: vm.nextStep)
                        case 2: StepUrgeView(urge: $vm.spendingUrge, note: $vm.note, onNext: vm.nextStep)
                        case 3: StepSleepView(enabled: $vm.sleepQualityEnabled, quality: $vm.sleepQuality, onNext: vm.nextStep)
                        case 4: StepGoalView(goal: $vm.goalToday, onSubmit: {
                            vm.submit(context: context)
                            navigateToCoach = true
                        })
                        default: EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: vm.currentStep)
                }
            }
            .navigationDestination(isPresented: $navigateToCoach) {
                if let checkIn = vm.savedCheckIn, let prof = profile {
                    AICoachView(checkIn: checkIn, profile: prof, onDone: { dismiss() })
                }
            }
        }
    }
}

// MARK: - Step 1: Stress
private struct StepStressView: View {
    @Binding var stressLevel: Double
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    stepHeader(icon: "waveform.path.ecg", title: "Stress Level",
                               subtitle: "How stressed are you feeling right now?")
                    GlassCard {
                        VStack(spacing: 16) {
                            Text("\(Int(stressLevel))")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(stressColor)
                            Slider(value: $stressLevel, in: 1...10, step: 1)
                                .tint(stressColor)
                            HStack {
                                Text("😌 Calm").font(.caption2).foregroundStyle(.secondary)
                                Spacer()
                                Text("😰 Very stressed").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)
            }
            PrimaryButton(title: "Next") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }

    private var stressColor: Color {
        switch Int(stressLevel) {
        case 1...3: return Color.eqMint
        case 4...6: return .yellow
        default:    return .orange
        }
    }
}

// MARK: - Step 2: Urge
private struct StepUrgeView: View {
    @Binding var urge: SpendingUrge
    @Binding var note: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    stepHeader(icon: "cart.badge.questionmark", title: "Spending Urges",
                               subtitle: "Have you felt any urge to spend today?")
                    VStack(spacing: 10) {
                        ForEach(SpendingUrge.allCases, id: \.self) { option in
                            SelectionRow(label: option.rawValue, isSelected: urge == option) {
                                urge = option
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Optional note")
                                .font(.caption).fontWeight(.semibold).foregroundStyle(Color.eqMint)
                            TextField("What triggered it? (optional)", text: $note, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)
            }
            PrimaryButton(title: "Next") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }
}

// MARK: - Step 3: Sleep
private struct StepSleepView: View {
    @Binding var enabled: Bool
    @Binding var quality: Double
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    stepHeader(icon: "moon.stars.fill", title: "Sleep Quality",
                               subtitle: "How well did you sleep last night?")
                    GlassCard {
                        VStack(spacing: 16) {
                            Toggle("Track sleep quality", isOn: $enabled)
                                .tint(Color.eqMint)
                                .foregroundStyle(.white)
                            if enabled {
                                HStack {
                                    Text("Quality")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(Int(quality)) / 5")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.eqMint)
                                }
                                Slider(value: $quality, in: 1...5, step: 1)
                                    .tint(Color.eqMint)
                                HStack {
                                    Text("😴 Poor").font(.caption2).foregroundStyle(.secondary)
                                    Spacer()
                                    Text("😊 Great").font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: enabled)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)
            }
            PrimaryButton(title: "Next") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }
}

// MARK: - Step 4: Goal
private struct StepGoalView: View {
    @Binding var goal: DailyGoal
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    stepHeader(icon: "flag.fill", title: "Today's Goal",
                               subtitle: "What's your top financial focus today?")
                    VStack(spacing: 10) {
                        ForEach(DailyGoal.allCases, id: \.self) { option in
                            SelectionRow(label: option.rawValue, isSelected: goal == option) {
                                goal = option
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)
            }
            PrimaryButton(title: "Submit & Get Insights") { onSubmit() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }
}

// MARK: - Shared helpers
private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
    VStack(spacing: 10) {
        Image(systemName: icon)
            .font(.system(size: 40))
            .foregroundStyle(Color.eqMint)
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 24)
}

private struct SelectionRow: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 15)
            .background(isSelected ? Color.eqMint : Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
