import SwiftUI
import SwiftData

// MARK: - Impulse Mode Entry Point
struct ImpulseModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var step: ImpulseStep = .trigger
    @State private var selectedTrigger: ImpulseTrigger? = nil
    @State private var urgeStrength: Double = 5

    private var profile: UserProfile? { profiles.first }

    enum ImpulseStep { case trigger, urge, coaching }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.09, blue: 0.07),
                    Color(red: 0.15, green: 0.11, blue: 0.09)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                stepContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .animation(.spring(response: 0.38, dampingFraction: 0.88), value: step)
    }

    // MARK: Nav bar
    private var navBar: some View {
        HStack {
            Button {
                switch step {
                case .trigger:  dismiss()
                case .urge:     step = .trigger
                case .coaching: step = .urge
                }
            } label: {
                Image(systemName: step == .trigger ? "xmark" : "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            Spacer()
            Text("⚡ Impulse Mode")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(dotColor(for: i))
                        .frame(width: stepIndex == i ? 18 : 6, height: 6)
                        .animation(.spring(response: 0.3), value: step)
                }
            }
        }
        .padding(.horizontal, Theme.lg)
        .padding(.top, Theme.md)
        .padding(.bottom, Theme.lg)
    }

    private var stepIndex: Int {
        switch step {
        case .trigger:  return 0
        case .urge:     return 1
        case .coaching: return 2
        }
    }

    private func dotColor(for index: Int) -> Color {
        index <= stepIndex ? Color.orange : Color.white.opacity(0.15)
    }

    // MARK: Step routing
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .trigger:
            TriggerStepView(selected: $selectedTrigger) {
                step = .urge
            }
        case .urge:
            UrgeStrengthStepView(urge: $urgeStrength, trigger: selectedTrigger) {
                step = .coaching
            }
        case .coaching:
            ImpulseCoachingView(
                trigger: selectedTrigger,
                urgeStrength: Int(urgeStrength),
                profile: profile,
                modelContext: modelContext,
                onDone: { dismiss() }
            )
        }
    }
}

// MARK: - Trigger enum
enum ImpulseTrigger: String, CaseIterable, Identifiable {
    case sale           = "Sale / discount"
    case boredom        = "Bored scrolling"
    case stress         = "Stress"
    case socialPressure = "Social pressure"
    case other          = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sale:           return "tag.fill"
        case .boredom:        return "moon.zzz.fill"
        case .stress:         return "waveform.path.ecg"
        case .socialPressure: return "person.2.fill"
        case .other:          return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .sale:           return .orange
        case .boredom:        return .purple
        case .stress:         return .red.opacity(0.9)
        case .socialPressure: return .blue.opacity(0.85)
        case .other:          return .gray
        }
    }
}

// MARK: - Step 1: Trigger Picker
private struct TriggerStepView: View {
    @Binding var selected: ImpulseTrigger?
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Theme.xs) {
                Text("⚡")
                    .font(.system(size: 44))
                Text("What triggered this?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Naming it helps you pause before spending.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.xl)
            .padding(.bottom, Theme.xl)

            VStack(spacing: Theme.xs) {
                ForEach(ImpulseTrigger.allCases) { trigger in
                    TriggerRow(trigger: trigger, isSelected: selected == trigger) {
                        withAnimation(.easeInOut(duration: 0.18)) { selected = trigger }
                    }
                }
            }
            .padding(.horizontal, Theme.lg)

            Spacer()

            PrimaryButton(
                title: "Next — How strong is it?",
                isDisabled: selected == nil
            ) { onNext() }
            .padding(.horizontal, Theme.lg)
            .padding(.bottom, Theme.xxl)
        }
    }
}

private struct TriggerRow: View {
    let trigger: ImpulseTrigger
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.md) {
                ZStack {
                    Circle()
                        .fill(trigger.color.opacity(isSelected ? 0.25 : 0.10))
                        .frame(width: 40, height: 40)
                    Image(systemName: trigger.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(isSelected ? trigger.color : .white.opacity(0.45))
                }
                Text(trigger.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.65))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(trigger.color)
                        .font(.system(size: 17))
                }
            }
            .padding(.horizontal, Theme.md)
            .padding(.vertical, 13)
            .background(isSelected ? trigger.color.opacity(0.10) : Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(isSelected ? trigger.color.opacity(0.35) : Color.white.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 2: Urge Strength Slider
private struct UrgeStrengthStepView: View {
    @Binding var urge: Double
    let trigger: ImpulseTrigger?
    let onNext: () -> Void

    private var urgeInt: Int { Int(urge) }

    private var urgeLabel: String {
        switch urgeInt {
        case 1...3: return "Mild"
        case 4...6: return "Moderate"
        case 7...9: return "Strong"
        case 10:    return "Overwhelming"
        default:    return "Mild"
        }
    }

    private var urgeColor: Color {
        switch urgeInt {
        case 1...3: return Theme.accentMint
        case 4...6: return .yellow
        case 7...9: return .orange
        default:    return .red.opacity(0.85)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let trigger {
                HStack(spacing: 6) {
                    Image(systemName: trigger.icon).font(.system(size: 11)).foregroundStyle(trigger.color)
                    Text(trigger.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(trigger.color.opacity(0.12))
                .clipShape(Capsule())
                .padding(.bottom, Theme.xl)
            }

            VStack(spacing: 6) {
                Text("🌡️")
                    .font(.system(size: 40))
                Text("How strong is the urge?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Be honest — this helps your AI coach respond.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, Theme.xl)
            .padding(.bottom, Theme.xl)

            VStack(spacing: Theme.lg) {
                VStack(spacing: 4) {
                    Text("\(urgeInt)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(urgeColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: urgeInt)
                    Text(urgeLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(urgeColor.opacity(0.8))
                        .animation(.easeInOut, value: urgeLabel)
                }

                VStack(spacing: 8) {
                    Slider(value: $urge, in: 1...10, step: 1)
                        .tint(urgeColor)
                        .animation(.spring(response: 0.3), value: urgeColor)
                    HStack {
                        Text("1 — Barely").font(.caption2).foregroundStyle(.white.opacity(0.35))
                        Spacer()
                        Text("10 — Can't resist").font(.caption2).foregroundStyle(.white.opacity(0.35))
                    }
                }
            }
            .padding(Theme.lg)
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, Theme.lg)

            Spacer()

            PrimaryButton(title: "Get My Coaching →") { onNext() }
                .padding(.horizontal, Theme.lg)
                .padding(.bottom, Theme.xxl)
        }
    }
}

// MARK: - Step 3: AI Coaching
private struct ImpulseCoachingView: View {
    let trigger: ImpulseTrigger?
    let urgeStrength: Int
    let profile: UserProfile?
    let modelContext: ModelContext
    let onDone: () -> Void

    @State private var coachState: CoachState = .loading
    @State private var showSavingsPrompt = false
    @State private var estimatedSavings: String = ""
    @State private var winRecorded = false

    enum CoachState {
        case loading
        case success(insight: String, action: String, ifThen: String)
        case error(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.sm) {
                if let trigger {
                    HStack(spacing: 5) {
                        Image(systemName: trigger.icon).font(.system(size: 11)).foregroundStyle(trigger.color)
                        Text(trigger.rawValue).font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(trigger.color.opacity(0.12))
                    .clipShape(Capsule())
                }
                HStack(spacing: 4) {
                    Text("Urge: \(urgeStrength)/10").font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.white.opacity(0.06))
                .clipShape(Capsule())
            }
            .padding(.bottom, Theme.lg)

            switch coachState {
            case .loading:
                loadingView
            case .success(let insight, let action, let ifThen):
                successView(insight: insight, action: action, ifThen: ifThen)
            case .error(let msg):
                errorView(msg)
            }
        }
        .task { await generateCoaching() }
        .sheet(isPresented: $showSavingsPrompt) {
            savingsPromptSheet
        }
    }

    // MARK: Savings Prompt Sheet
    private var savingsPromptSheet: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10).ignoresSafeArea()
            VStack(spacing: Theme.lg) {
                Text("🏆")
                    .font(.system(size: 48))
                Text("Impulse Win!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("You stopped an impulse purchase.\nHow much do you think you saved?")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)

                HStack {
                    Text("$")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.accentMint)
                    TextField("0", text: $estimatedSavings)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 100)
                }
                .padding(.horizontal, Theme.xl)
                .padding(.vertical, Theme.md)
                .background(.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(spacing: Theme.sm) {
                    Button {
                        recordWin()
                        showSavingsPrompt = false
                        onDone()
                    } label: {
                        Text("Record My Win 🎉")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accentMint)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    Button("Skip") {
                        recordWin(savings: 0)
                        showSavingsPrompt = false
                        onDone()
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(Theme.xl)
        }
        .presentationDetents([.medium])
    }

    // MARK: Loading
    private var loadingView: some View {
        VStack(spacing: Theme.xl) {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.orange.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(80 + i * 24), height: CGFloat(80 + i * 24))
                }
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.orange.opacity(0.85))
            }
            .frame(height: 130)

            VStack(spacing: Theme.xs) {
                Text("Generating your coaching…")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Your AI coach is crafting a personal response.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.xl)
            Spacer()
        }
        .padding(.top, Theme.lg)
    }

    // MARK: Success
    private func successView(insight: String, action: String, ifThen: String) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Theme.md) {
                VStack(spacing: 6) {
                    Text("🎯")
                        .font(.system(size: 36))
                    Text("Your Impulse Coach")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 4)

                coachBlock(icon: "lightbulb.fill", color: .orange, title: "💡 Insight", text: insight)
                coachBlock(icon: "hand.raised.fill", color: Theme.accentMint, title: "⚡ Pause Action", text: "• \(action)")
                coachBlock(icon: "arrow.triangle.branch", color: Color(red: 0.6, green: 0.5, blue: 1.0), title: "🧠 If-Then Plan", text: ifThen)

                VStack(spacing: Theme.sm) {
                    Button {
                        showSavingsPrompt = true
                    } label: {
                        Text("I'll wait — Record My Win 🏆")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accentMint)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    SecondaryButton(title: "I still want to spend", icon: "cart") { onDone() }
                }
                .padding(.top, Theme.sm)
            }
            .padding(.horizontal, Theme.lg)
            .padding(.bottom, Theme.xxl)
        }
    }

    private func coachBlock(icon: String, color: Color, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .textCase(.uppercase)
                .kerning(0.4)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(Theme.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: Error
    private func errorView(_ msg: String) -> some View {
        VStack(spacing: Theme.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(.orange.opacity(0.7))
            Text(msg)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await generateCoaching() }
            }
            .foregroundStyle(.orange)
            .fontWeight(.semibold)
            Spacer()
            PrimaryButton(title: "Back to Home", action: onDone)
                .padding(.horizontal, Theme.lg)
                .padding(.bottom, Theme.xxl)
        }
        .padding(.horizontal, Theme.xl)
    }

    // MARK: Win recording
    private func recordWin(savings: Double? = nil) {
        let amount: Double
        if let s = savings {
            amount = s
        } else {
            amount = Double(estimatedSavings) ?? 0
        }
        let win = ImpulseWin(
            trigger: trigger?.rawValue ?? "other",
            urgeStrength: urgeStrength,
            estimatedSavings: amount
        )
        modelContext.insert(win)
        try? modelContext.save()
    }

    // MARK: AI call
    private func generateCoaching() async {
        coachState = .loading

        guard Secrets.openAIKey != nil else {
            let fallback = staticFallback()
            coachState = .success(insight: fallback.0, action: fallback.1, ifThen: fallback.2)
            return
        }

        let triggerName = trigger?.rawValue ?? "an impulse"
        let profileName = profile?.name ?? "you"
        let profileGoal = profile?.primaryGoalRaw ?? "build savings"

        let snap = ProfileSnapshot(
            name: profileName,
            primaryGoal: profileGoal,
            baselineStress: profile?.baselineStress ?? 5
        )
        let ciSnap = CheckInSnapshot(
            stressLevel: urgeStrength,
            spendingUrge: trigger?.rawValue ?? "other",
            sleepQuality: nil,
            goalToday: profileGoal,
            note: "Impulse mode: \(triggerName)"
        )

        do {
            let (dto, _) = try await AIService.shared.generateInsight(profile: snap, checkIn: ciSnap)
            coachState = .success(insight: dto.insight, action: dto.action, ifThen: dto.if_then)
        } catch {
            let fallback = staticFallback()
            coachState = .success(insight: fallback.0, action: fallback.1, ifThen: fallback.2)
        }
    }

    private func staticFallback() -> (String, String, String) {
        switch trigger {
        case .sale:
            return (
                "Sales create urgency illusions.",
                "Set a 10-minute timer before checkout.",
                "If the timer ends and I still want it, then I'll check my savings goal first."
            )
        case .boredom:
            return (
                "Boredom shopping buys things, not relief.",
                "Stand up and drink a glass of water.",
                "If I feel bored and want to browse, then I'll text a friend or take a 5-minute walk instead."
            )
        case .stress:
            return (
                "Stress spending adds debt, not calm.",
                "Take 3 slow deep breaths right now.",
                "If I feel stressed and want to spend, then I'll write down what's actually bothering me first."
            )
        case .socialPressure:
            return (
                "Fitting in costs more than you think.",
                "Recall one savings goal you care about.",
                "If I feel pressure to spend socially, then I'll remember my goals outlast the moment."
            )
        case .other, .none:
            return (
                "You noticed the urge — that's already a win.",
                "Wait 10 more minutes before any action.",
                "If I feel an unplanned urge, then I'll ask: does this serve my goal?"
            )
        }
    }
}
