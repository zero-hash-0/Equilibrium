import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Int
    @Query private var profiles: [UserProfile]
    @Query(sort: \CheckIn.createdAt, order: .reverse) private var checkIns: [CheckIn]
    @Query(sort: \ImpulseWin.createdAt, order: .reverse) private var impulseWins: [ImpulseWin]
    @State private var vm = HomeViewModel()
    @State private var showCheckIn = false
    @State private var showAlreadyCheckedIn = false
    @State private var existingCheckIn: CheckIn? = nil
    @State private var showImpulseMode = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.lg) {
                    headerSection
                    wellnessCard
                    impulseBannerCard
                    checkInCard
                    if let insight = vm.latestInsight(from: checkIns) {
                        insightCard(insight)
                    }
                    impulseWinsCard
                    trendButton
                }
                .padding(.horizontal, Theme.lg)
                .padding(.top, Theme.md)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCheckIn) {
            CheckInFlowView()
        }
        .sheet(isPresented: $showImpulseMode) {
            ImpulseModeView()
        }
        .alert("Already Checked In", isPresented: $showAlreadyCheckedIn) {
            if existingCheckIn?.insight != nil {
                Button("View Coach") {
                    showCheckIn = true
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've already completed today's check-in.")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text("Hello, \(profile?.name ?? "there") 👋")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.accentMint.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.accentMint)
            }
        }
        .padding(.top, Theme.md)
    }

    private var impulseBannerCard: some View {
        Button { showImpulseMode = true } label: {
            HStack(spacing: Theme.md) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Text("⚡")
                        .font(.system(size: 24))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Feeling an urge to spend?")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Tap to open Impulse Mode")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.md)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.18), Color.orange.opacity(0.08)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var wellnessCard: some View {
        TitledCard(title: "Financial Wellness Score", icon: "heart.fill") {
            let score = vm.wellnessScore(from: checkIns)
            HStack(spacing: Theme.lg) {
                WellnessRing(score: score ?? 50, dimmed: score == nil)
                VStack(alignment: .leading, spacing: 6) {
                    if let score {
                        Text(WellnessScore.label(for: score))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(WellnessScore.explanation(for: score))
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("No data yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Complete your first check-in to see your score.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
        }
    }

    private var checkInCard: some View {
        let today = vm.todayCheckIn(from: checkIns)
        return TitledCard(title: "Today's Check-In", icon: "calendar.badge.checkmark",
            accessory: {
                statusBadge(done: today != nil)
            }) {
            PrimaryButton(title: today == nil ? "Start Check-In" : "View Today's Check-In") {
                let todayCI = vm.todayCheckIn(from: checkIns)
                if todayCI != nil {
                    existingCheckIn = todayCI
                    showAlreadyCheckedIn = true
                } else {
                    showCheckIn = true
                }
            }
        }
    }

    private func statusBadge(done: Bool) -> some View {
        Text(done ? "Done" : "Not done")
            .font(.caption).fontWeight(.semibold)
            .foregroundStyle(done ? .black : Theme.textSecondary)
            .padding(.horizontal, Theme.xs).padding(.vertical, 4)
            .background(done ? Theme.accentMint : Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    private func insightCard(_ insight: AIInsight) -> some View {
        TitledCard(title: "Latest AI Insight", icon: "sparkles") {
            Text(insight.insightText)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(3)
        }
    }

    // MARK: Impulse Wins Card
    private var impulseWinsCard: some View {
        let weekWins = winsThisWeek
        let totalSaved = weekWins.reduce(0) { $0 + $1.estimatedSavings }

        return TitledCard(title: "Impulse Wins", icon: "trophy.fill", accent: .orange) {
            if weekWins.isEmpty {
                VStack(spacing: Theme.xs) {
                    Text("No wins yet this week")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Use Impulse Mode when you feel the urge to spend. Every pause is a win.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack(alignment: .top, spacing: Theme.lg) {
                    VStack(spacing: 2) {
                        Text("\(weekWins.count)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                        Text("paused\nthis week")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Divider().frame(height: 50).background(Color.white.opacity(0.1))
                    VStack(spacing: 2) {
                        Text(totalSaved > 0 ? "$\(Int(totalSaved))" : "—")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accentMint)
                        Text("estimated\nsaved")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
            }
        }
    }

    private var winsThisWeek: [ImpulseWin] {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return impulseWins.filter { $0.createdAt >= startOfWeek }
    }

    private var trendButton: some View {
        HStack(spacing: Theme.sm) {
            SecondaryButton(title: "View Trends", icon: "chart.line.uptrend.xyaxis") {
                selectedTab = 1
            }
            SecondaryButton(title: "Settings", icon: "gearshape.fill") {
                selectedTab = 2
            }
        }
    }
}

// MARK: - Wellness Ring
private struct WellnessRing: View {
    let score: Int
    var dimmed: Bool = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.accentMint.opacity(0.15), lineWidth: 10)
            Circle()
                .trim(from: 0, to: dimmed ? 0 : (appeared ? CGFloat(score) / 100 : 0))
                .stroke(
                    Theme.accentGradient,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: appeared)
            VStack(spacing: 1) {
                Text(dimmed ? "—" : "\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(dimmed ? Theme.textSecondary : Theme.accentMint)
                if !dimmed {
                    Text("/ 100").font(.caption2).foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
    }
}
