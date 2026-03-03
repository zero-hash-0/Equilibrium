import SwiftUI
import SwiftData

struct AICoachView: View {
    @Environment(\.modelContext) private var context
    let checkIn: CheckIn
    let profile: UserProfile
    let onDone: () -> Void

    @State private var vm = CoachViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.eqGraphite, Color.eqSlate],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    checkInSummaryCard
                    insightSection
                    Spacer(minLength: 20)
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .task {
            await vm.loadInsight(checkIn: checkIn, profile: profile, context: context)
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(Color.eqMint)
            Text("Your AI Coach")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Based on today's check-in")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var checkInSummaryCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Today's Check-In", systemImage: "calendar")
                    .font(.caption).fontWeight(.semibold).foregroundStyle(Color.eqMint)
                Divider().background(.secondary.opacity(0.3))
                summaryRow("Stress", value: "\(checkIn.stressLevel) / 10")
                summaryRow("Spending urge", value: checkIn.spendingUrge)
                if let sleep = checkIn.sleepQuality {
                    summaryRow("Sleep quality", value: "\(sleep) / 5")
                }
                summaryRow("Goal today", value: checkIn.goalToday)
                if let note = checkIn.note, !note.isEmpty {
                    summaryRow("Note", value: note)
                }
            }
        }
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium).foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var insightSection: some View {
        switch vm.state {
        case .loading:
            GlassCard {
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.eqMint)
                        .scaleEffect(1.2)
                    Text("Generating your insight…")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

        case .success(let insight):
            VStack(spacing: 16) {
                insightBlock(
                    icon: "lightbulb.fill",
                    title: "Insight",
                    text: insight.insightText,
                    accent: Color.eqMint
                )
                insightBlock(
                    icon: "arrow.right.circle.fill",
                    title: "One Small Action",
                    text: "• \(insight.actionText)",
                    accent: .cyan
                )
                insightBlock(
                    icon: "arrow.triangle.branch",
                    title: "If-Then Plan",
                    text: insight.ifThenText,
                    accent: .purple.opacity(0.8)
                )
            }

        case .error(let msg):
            GlassCard {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.orange)
                    Text(msg)
                        .font(.subheadline).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await vm.loadInsight(checkIn: checkIn, profile: profile, context: context) }
                    }
                    .foregroundStyle(Color.eqMint)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
    }

    private func insightBlock(icon: String, title: String, text: String, accent: Color) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: icon)
                    .font(.caption).fontWeight(.semibold).foregroundStyle(accent)
                Text(text)
                    .font(.body)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if case .success = vm.state {
                Button {
                    Task { await vm.regenerate(checkIn: checkIn, profile: profile, context: context) }
                } label: {
                    HStack(spacing: 8) {
                        if vm.isRegenerating {
                            ProgressView().progressViewStyle(.circular).tint(Color.eqMint).scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Regenerate (3 max/day)")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.eqMint)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.eqMint.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(vm.isRegenerating)
            }

            PrimaryButton(title: "Back to Home") { onDone() }
        }
    }
}
