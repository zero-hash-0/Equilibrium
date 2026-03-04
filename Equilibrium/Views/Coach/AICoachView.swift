import SwiftUI
import SwiftData

struct AICoachView: View {
    @Environment(\.modelContext) private var modelContext
    let checkIn: CheckIn
    let profile: UserProfile
    let onDone: () -> Void

    @State private var vm = AICoachViewModel()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    headerSection
                    summaryCard
                    insightSection
                    actionSection
                }
                .padding(.horizontal, Theme.lg)
                .padding(.top, Theme.md)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .task {
            await vm.loadOrGenerate(modelContext: modelContext, profile: profile, checkIn: checkIn)
        }
    }

    private var headerSection: some View {
        VStack(spacing: Theme.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: Theme.iconLG))
                .foregroundStyle(Theme.accentMint)
            Text("Your AI Coach")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text("Based on today's check-in")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, Theme.md)
    }

    private var summaryCard: some View {
        TitledCard(title: "Today's Check-In", icon: "calendar") {
            VStack(spacing: Theme.xs) {
                summaryRow("Stress", value: "\(checkIn.stressLevel) / 10")
                summaryRow("Spending urge", value: checkIn.spendingUrgeRaw)
                if let sleep = checkIn.sleepQuality { summaryRow("Sleep", value: "\(sleep) / 5") }
                summaryRow("Goal today", value: checkIn.goalTodayRaw)
                if let note = checkIn.note, !note.isEmpty { summaryRow("Note", value: note) }
            }
        }
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium).foregroundStyle(Theme.textPrimary)
        }
    }

    @ViewBuilder
    private var insightSection: some View {
        switch vm.state {
        case .idle:
            EmptyView()
        case .loading:
            LiquidGlassCard {
                VStack(spacing: Theme.md) {
                    ProgressView().progressViewStyle(.circular).tint(Theme.accentMint).scaleEffect(1.2)
                    Text("Generating your insight…")
                        .font(.subheadline).foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, Theme.xl)
            }
        case .success(let insight):
            VStack(spacing: Theme.md) {
                insightBlock(emoji: "💡", title: "Insight",
                             text: insight.insightText, accent: Theme.accentMint)
                insightBlock(emoji: "⚡", title: "One Small Action",
                             text: "• \(insight.actionText)", accent: Theme.accentCyan)
                insightBlock(emoji: "🧠", title: "If-Then Plan",
                             text: insight.ifThenText, accent: .purple.opacity(0.85))
            }
        case .error(let msg):
            LiquidGlassCard {
                VStack(spacing: Theme.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32)).foregroundStyle(.orange)
                    Text(msg).font(.subheadline).foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await vm.loadOrGenerate(modelContext: modelContext, profile: profile, checkIn: checkIn) }
                    }
                    .foregroundStyle(Theme.accentMint).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).padding(.vertical, Theme.md)
            }
        }
    }

    private func insightBlock(emoji: String, title: String, text: String, accent: Color) -> some View {
        TitledCard(title: "\(emoji) \(title)", icon: "", accent: accent) {
            Text(text)
                .font(.body).foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionSection: some View {
        VStack(spacing: Theme.sm) {
            if case .success = vm.state {
                let remaining = vm.remainingRegenerations
                SecondaryButton(
                    title: remaining > 0
                        ? "Regenerate (\(remaining) left today)"
                        : "Limit Reached (3/day)",
                    icon: "arrow.clockwise",
                    destructive: false
                ) {
                    Task { await vm.regenerate(modelContext: modelContext, profile: profile, checkIn: checkIn) }
                }
                .disabled(!vm.canRegenerate)
                .opacity(vm.canRegenerate ? 1 : 0.5)
            }
            PrimaryButton(title: "Back to Home", action: onDone)
        }
    }
}
